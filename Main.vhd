----------------------------------------------------------------------------------
-- Company: SDU TEK
-- Engineer: Daniel Tofte Schøn
--
-- Create Date: 03/03/2019 04:04:37 PM
-- Design Name:
-- Module Name: Main - Behavioral
-- Project Name: PANTILT system
-- Target Devices: BASYS 3
-- Tool Versions: VHL 2008
-- Description: Test Module
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Main is
port(
    clk         :   in  std_logic;
    btnD        :   in  std_logic;  -- conc with data to make 8bit
    sw          :   in  std_logic_vector (15 downto 0);
    led         :   out std_logic_vector (15 downto 0);
    RsTx        :   out std_logic;
    RsRx        :   in  std_logic
    );
end Main;

architecture Behavioral of Main is

    component UART_TX_topmodule is
    port(
        send        :   in  std_logic;
        r_w         :   in  std_logic;  -- read or write, databyte is only 7
        clk         :   in  std_logic;
        data        :   in  std_logic_vector (6 downto 0);
        ready       :   out std_logic;
        RsTx        :   out std_logic
        );
    end component;
    
    component UART_RS_topmodule is
    port(
        clk                     :   in std_logic;
        RsRx                    :   in std_logic;
        read_d                  :   in std_logic;
        data                    :   out std_logic_vector (7 downto 0);           -- data to be send
        ready                   :   out std_logic
        );
    end component;
    
    component UART_RS is
    generic(
        baud                    :   integer := 9600;                                -- baud rate
        clk_board               :   integer := 100000000                            -- clk board
        );
        -- checking if parity
    port(
        clk                     :   in std_logic;
        RsRx                    :   in std_logic;
        data                    :   out std_logic_vector (7 downto 0);              -- data to be send
        ready                   :   out std_logic                                   -- is ready to sent if high send
        );
    end component;


    constant clk_c      :   integer := 100000000;
    signal counter      :   integer range 0 to clk_c;
    signal send_buf     :   std_logic;
    signal b_ready      :   std_logic;
    signal b_read       :   std_logic;
    signal b_data       :   std_logic_vector (7 downto 0);
    signal more_buf     :   std_logic_vector (15 downto 0);

-------
begin

    process(clk) begin
        if(rising_edge(clk)) then
            if (counter = clk_c) then
                counter <= 0;
            elsif (counter = 0) then
                send_buf <= '1';
                counter <= counter + 1;
            elsif (counter = 6) then
                send_buf <= '0';
                counter <= counter + 1;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

UUT2: UART_TX_topmodule
    port map(send => send_buf, r_w => sw(7), clk => clk, data => sw(6 downto 0), ready => led(0), RsTx => RsTx);
    
UUT3: UART_RS_topmodule
    port map(clk => clk, RsRx => RsRx, read_d => b_read, data => b_data, ready => b_ready);
    
    process(clk) begin
        if(rising_edge(clk)) then
            if(b_ready = '1') then
                more_buf(7 downto 0) <= b_data;
                b_read <= '1';
            else
                more_buf(15 downto 8) <= more_buf(7 downto 0);
                b_read <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
