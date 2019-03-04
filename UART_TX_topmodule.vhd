----------------------------------------------------------------------------------
-- Company: SDU - TEK
-- Engineer: Daniel Tofte Schøn
--
-- Create Date: 03/03/2019 02:57:24 PM
-- Design Name:
-- Module Name: UART_TX_topmodule - Behavioral
-- Project Name: PANTILT SYSTEM
-- Target Devices: BASYS 3
-- Tool Versions: Vivado 2018.3
-- Description:  A user interface to UART_TX.vhd module
--
-- Dependencies: VHDL-2008.
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_TX_topmodule is
    port(
        send              :   in  std_logic;
        r_w               :   in  std_logic;  -- conc with data to make 8bit
        clk               :   in  std_logic;
        data              :   in  std_logic_vector (6 downto 0);
        ready             :   out std_logic;
        RsTx              :   out std_logic
        );
end UART_TX_topmodule;

architecture Behavioral of UART_TX_topmodule is

    ----------------------------COMPONENTS--------------------------------------
    -- UART Transmiter Module
    ----------------------------------------------------------------------------
    component UART_TX is
    generic(
        baud              :   integer := 9600;        -- baud rate
        clk_board         :   integer := 100000000   -- clk board
        );
    port(
        send              :   in  std_logic;
        clk               :   in  std_logic;
        data              :   in  std_logic_vector (7 downto 0);
        ready             :   out std_logic;
        RsTx              :   out std_logic
        );
    end component;
    ----------------------------STATE-------------------------------------------
    type state_type is (TX_RDY, TX_SEND_CHAR, TX_SEND_WAIT);
    ----------------------------CONSTANTS---------------------------------------
    constant active       :   std_logic := '1'; -- active high
    constant not_active   :   std_logic := '0';
    constant deactivate   :   std_logic := '0';
    constant max_delay    :   integer   := 3;
    ----------------------------SIGNALS-----------------------------------------
    signal state          :   state_type;
    signal uart_rdy       :   std_logic;
    signal uart_send      :   std_logic;
    signal uart_data      :   std_logic_vector (7 downto 0);
    signal send_tx        :   std_logic := '0';

    signal counter_dela   :   integer range 0 to max_delay := 0;

    signal b_ready        :   std_logic; -- buffer output ready
    ----------------------------BEGIN-------------------------------------------

begin

    uart_data <= r_w & data;
    ready <= b_ready;


    process(clk) begin
        if (rising_edge(clk)) then
            case( state ) is
                when TX_RDY =>
                    if (send = active) then
                        state <= TX_SEND_CHAR;
                    end if;
                    counter_dela <= 0;
                when TX_SEND_CHAR =>
                    if (b_ready = active) and (counter_dela = 0) then
                        send_tx <= '1';
                        counter_dela <= counter_dela + 1;
                    elsif (counter_dela = max_delay) then
                        send_tx <= '0';
                        counter_dela <= 0;
                        state <= TX_SEND_WAIT;
                    else
                        counter_dela <= counter_dela + 1;
                    end if;
                when TX_SEND_WAIT =>
                    if (b_ready = active) then
                        state <= TX_RDY;
                    end if;
            end case;
        end if;
    end process;

TX: UART_TX
    generic map(baud => 115200, clk_board => 100000000)
    port map(send => send_tx, clk => clk, data => uart_data, ready => b_ready, RsTx => RsTx);


end Behavioral;
