----------------------------------------------------------------------------------
-- Company: SDU - TEK
-- Engineer: Daniel Tofte Schøn
--
-- Create Date: 03/04/2019 08:22:44 AM
-- Design Name:
-- Module Name: UART_RS - Behavioral
-- Project Name:
-- Target Devices: BASYS 3 - ARTIC 7 - 236 cpg
-- Tool Versions: VHDL 2008
-- Description: Simple non-top reciever module
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
use IEEE.std_logic_arith.ALL;

entity UART_RS is
generic(
    baud        :   integer := 9600;                    -- baud rate
    clk_board   :   integer := 100000000                -- clk board
    );
    -- checking if parity
port(
    read_sig    :   in  std_logic;
    data        :   out std_logic_vector (7 downto 0);  -- data to be send
    ready       :   out std_logic;                      -- is ready to sent if high send
    parity_fail :   out std_logic;
    uart_rs     :   out std_logic                       -- IO Tx
    );
end UART_RS;

architecture Behavioral of UART_RS is
    ----------------------------FUNCTIONS---------------------------------------

    ----------------------------CONSTANTS---------------------------------------
    constant baud_ref       :   integer := clk_board/baud;
    constant bit_max_ref    :   integer := 11;
    constant data_size      :   integer := 8;
    constant RESET_INT      :   integer := 0;
    constant LOW            :   std_logic := '0';
    constant HIGH           :   std_logic := '1';
    ----------------------------CODE SIMPLIFYERS--------------------------------
    constant stop_bit       :   std_logic := '1';
    constant start_bit      :   std_logic := '0';
    constant inactive       :   std_logic := '1';
    constant even_partity   :   std_logic := '1'; -- mode
    ----------------------------TYPE--------------------------------------------
    type    state_type is (WAIT_RS, READ_RS, WAIT_RS, CHECK_RS);
    ----------------------------SIGNALS-----------------------------------------
    signal state_uart       :   state_type := WAIT_RS;
    signal timer_uart       :   integer := 0;
    signal rsData           :   std_logic_vector ((bit_max_ref-1) downto 0);
    signal rsBit            :   std_logic;
    signal current_bitIndex :   integer range 0 TO bit_max_ref := 0;
    signal buffer_data      :   std_logic_vector (8 downto 0);
    ----------------------------START-------------------------------------------

    begin

    ----------------------------PROCESS-----------------------------------------
    -- input: runs if clk runs                                                --
    -- function : UART transmit to PC or other peripheral                     --
    ----------------------------------------------------------------------------
    process(clk) begin
        if (rising_edge(clk)) then
            case( state_uart ) is

    ----------------------------------------------------------------------------
                when WAIT_RS =>
                    if (uart_rs = LOW) then -- start signal
                        state_uart <= READ_RS; -- preparing to read
                        current_bitIndex <= RESET_INT;
                        timer_uart <= RESET_INT;
                        rsData <= x"000";
                    end if;
    ----------------------------------------------------------------------------
                when READ_RS =>
                -- init timer!!!!!!!
                    if (current_bitIndex = bit_max_ref) then
                        state_uart <= WAIT_RS;
                        data(current_bitIndex) <= uart_rs;
                        current_bitIndex <= current_bitIndex + 1;
                    end if;
    ----------------------------------------------------------------------------
                when WAIT_RS =>
                    if (timer_uart = baud_ref) then
                        timer_uart <= 0;
                        state_uart <= READ_RS;
                    else
                        timer_uart <= timer_uart + 1;
                    end if;
    ----------------------------------------------------------------------------
                when CHECK_RS =>
    ----------------------------------------------------------------------------
                when others =>
                    -- ASSERT!!!!
                    state_uart <= WAIT_RS;

            end case;

        end if;
    end process;
    ----------------------------------------------------------------------------
    uart_rs <= tx;
    ready <= '1' when (state_uart = READ_RS) else '0';
    ----------------------------------------------------------------------------
end Behavioral;
