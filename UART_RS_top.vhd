----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/04/2019 11:08:28 AM
-- Design Name:
-- Module Name: UART_RS_top - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
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

entity UART_RS_topmodule is
    port(
        clk                     :   in std_logic;
        RsRx                    :   in std_logic;
        read_d                  :   in std_logic;
        data                    :   out std_logic_vector (7 downto 0);           -- data to be send
        ready                   :   out std_logic
        );
end UART_RS_topmodule;

architecture Behavioral of UART_RS_topmodule is
    ----------------------------COMPONENTS--------------------------------------
    -- UART Reciever Module
    ----------------------------------------------------------------------------
 component UART_RS is
    generic(
        baud                    :   integer := 9600;                            -- baud rate
        clk_board               :   integer := 100000000                        -- clk board
        );
    port(
        clk                     :   in std_logic;
        RsRx                    :   in std_logic;
        data                    :   out std_logic_vector (7 downto 0);          -- data to be send
        ready                   :   out std_logic                              -- is ready to sent if high send
        );
    end component;
    ----------------------------STATE-------------------------------------------
    type state_type is (RECIEVE, READ_DATA);
    ----------------------------SIGNALS-----------------------------------------
    constant HIGH               :   std_logic := '1';
    constant LOW                :   std_logic := '0';
    ----------------------------SIGNALS-----------------------------------------
    signal state_topm           :   state_type := RECIEVE;
    signal b_ready              :   std_logic;
    signal b_parity_fail        :   std_logic;
    signal b_sync_fail          :   std_logic;
    signal b_data               :   std_logic_vector(7 downto 0);
    ----------------------------BEGIN-------------------------------------------
    begin
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if (falling_edge(clk)) then
            case( state_topm ) is
    ----------------------------------------------------------------------------
                when RECIEVE =>
                    if (b_ready = HIGH) then
                          data <= b_data;                                       -- parallel shift register
                         ready <= HIGH;                                         -- set data high
                    state_topm <= READ_DATA;                                    -- change state to READ data
                    end if;
    ----------------------------------------------------------------------------
                when READ_DATA =>
                    if (read_d = HIGH) then
                        ready <= LOW;
                   state_topm <= RECIEVE;                                       -- IS RECIEVED
                    end if;
    ----------------------------------------------------------------------------
                when others =>
                   state_topm <= RECIEVE;                                       -- SUPPOSED TO PUSH A ERROR MESSAGE
    ----------------------------------------------------------------------------
            end case;
        end if;
    end process;
    ----------------------------PORT MAP----------------------------------------
UUT:UART_RS
    generic map(baud => 115200, clk_board => 100000000)
    port map(clk => clk, RsRx => RsRx, data => b_data, ready => b_ready);
    ----------------------------------------------------------------------------


end Behavioral;
