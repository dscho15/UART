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
end UART_RS;
architecture Behavioral of UART_RS is
    ----------------------------FUNCTIONS---------------------------------------
    ----------------------------CONSTANTS---------------------------------------
    constant baud_ref       :   integer := clk_board/baud;
    constant baud_ref_half  :   integer := clk_board/(2*baud);
    constant bit_max_ref    :   integer := 10;
    constant RESET_INT      :   integer := 0;
    constant LOW            :   std_logic := '0';
    constant HIGH           :   std_logic := '1';
    ----------------------------TYPE--------------------------------------------
    type    state_type is   (IDLE, OFFSET_RS, READ_RS, WAIT_RS, CHECK_RS, DONE_RS, WAIT_NEXT);
    ----------------------------SIGNALS-----------------------------------------
    signal state_uart       :   state_type := IDLE;
    signal timer_uart       :   integer := 0;
    signal rsData           :   std_logic_vector ((bit_max_ref-1) downto 0);
    signal rsBit            :   std_logic;
    signal bitIndex         :   integer range 0 TO bit_max_ref := 0;
    ----------------------------START-------------------------------------------
    begin
    ----------------------------PROCESS-----------------------------------------
    -- input: runs if clk runs                                                --
    -- function : READ SIGANLS from RS                                        --
    ----------------------------------------------------------------------------
    process(clk) begin
        if (rising_edge(clk)) then
            case( state_uart ) is
    ----------------------------------------------------------------------------
                when IDLE =>
    ----------------------------------------------------------------------------
                         if (RsRx = LOW) then                                   -- start signal
                rsData(bitIndex) <= RsRx;                                       --
                        bitIndex <= bitIndex + 1;                               --
                      state_uart <= OFFSET_RS;                                  -- preparing to read
                    bitIndex     <= RESET_INT;                                  --
                    timer_uart   <= RESET_INT;                                  --
                         end if;
                    ready        <= LOW;                                        --

    ----------------------------------------------------------------------------
                when OFFSET_RS =>
    ----------------------------------------------------------------------------
                   if (timer_uart = baud_ref_half) then                         --
                      timer_uart <= 0;                                          -- reset
                      state_uart <= WAIT_RS;                                    --
                   else
                      timer_uart <= timer_uart + 1;                             --
                   end if;
    ----------------------------------------------------------------------------
                when READ_RS =>
    ----------------------------------------------------------------------------
                  data(bitIndex) <= RsRx;                                    --
                        bitIndex <= bitIndex + 1;                               --
                      state_uart <= WAIT_RS;                                    --
    ----------------------------------------------------------------------------
                when WAIT_RS =>
    ----------------------------------------------------------------------------
                     if (bitIndex = bit_max_ref) then
                      state_uart <= CHECK_RS;
                    elsif (timer_uart = baud_ref) then
                      timer_uart <= RESET_INT;                                  --
                      state_uart <= READ_RS;
                    else
                      timer_uart <= timer_uart + 1;
                    end if;
    ----------------------------------------------------------------------------
                when CHECK_RS =>
    ----------------------------------------------------------------------------
                    if (rsData(0) = LOW) and (rsData(9) = HIGH) then
                      state_uart <= DONE_RS;
                    else
                      timer_uart <= RESET_INT;
                      state_uart <= WAIT_NEXT;                                  -- FAILED
                    end if;
    ----------------------------------------------------------------------------
                when DONE_RS =>
    ----------------------------------------------------------------------------
                            data <= rsData(8 downto 1);                         -- DATA IS OUT - Parallel Shift Register!!
                           ready <= HIGH;                                       -- MADE READY TO READ
                      timer_uart <= RESET_INT;
                      state_uart <= WAIT_NEXT;                                  --
    ----------------------------------------------------------------------------
                when WAIT_NEXT =>
    ----------------------------------------------------------------------------
                    if (timer_uart = 50) then
                      timer_uart <= RESET_INT;                                  --
                      state_uart <= IDLE;                                       --
                    else                                                        --
                      timer_uart <= timer_uart + 1;                             --
                    end if;
    ----------------------------------------------------------------------------
            end case;
        end if;
    end process;
    ----------------------------------------------------------------------------
end Behavioral;
