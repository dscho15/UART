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
    uart_rs                 :   in  std_logic;
    data                    :   out std_logic_vector (7 downto 0);              -- data to be send
    ready                   :   out std_logic;                                  -- is ready to sent if high send
    parity_fail             :   out std_logic := '0';
    sync_fail               :   out std_logic := '0'
    );
end UART_RS;

architecture Behavioral of UART_RS is
    ----------------------------FUNCTIONS---------------------------------------

    ----------------------------CONSTANTS---------------------------------------
    constant baud_ref       :   integer := clk_board/baud;
    constant bit_max_ref    :   integer := 11;
    constant RESET_INT      :   integer := 0;
    constant LOW            :   std_logic := '0';
    constant HIGH           :   std_logic := '1';
    ----------------------------CODE SIMPLIFYERS--------------------------------
    constant stop_bit       :   std_logic := '1';
    constant start_bit      :   std_logic := '0';
    constant inactive       :   std_logic := '1';
    ----------------------------TYPE--------------------------------------------
    type    state_type is (WAIT_RS, OFFSET_RS, READ_RS, CHECK_RS, DONE_RS);
    type    state_par  is (INIT_PAR, DONE_PAR);
    ----------------------------SIGNALS-----------------------------------------
    signal state_uart       :   state_type := WAIT_RS;
    signal state_parity     :   state_par := INIT_PAR;
    signal timer_uart       :   integer := 0;
    signal rsData           :   std_logic_vector ((bit_max_ref-1) downto 0);
    signal rsBit            :   std_logic;
    signal bitIndex         :   integer range 0 TO bit_max_ref := 0;
    signal parity           :   std_logic;
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
                when WAIT_RS =>
    ----------------------------------------------------------------------------
                      if (uart_rs = LOW) then                                   -- start signal
                rsData(bitIndex) <= uart_rs;                                    --
                        bitIndex <= bitIndex + 1;                               --
                      state_uart <= READ_RS;                                    -- preparing to read
                      end if;
                    rsData       <= x"000";                                     -- reset data
                    bitIndex     <= RESET_INT;                                  -- reset
                    timer_uart   <= RESET_INT;                                  -- reset
                    state_parity <= INIT_PAR;                                   -- reset
                    ready        <= LOW;                                        --
                    sync_fail    <= LOW;                                        --
                    parity_fail  <= LOW;                                        --
                    parity       <= LOW;                                        --
    ----------------------------------------------------------------------------
                when OFFSET_RS =>
    ----------------------------------------------------------------------------
                   if (timer_uart = baud_ref/2) then                            --
                      timer_uart <= 0;                                          -- reset
                      state_uart <= WAIT_RS;                                    --
                   else
                      timer_uart <= timer_uart + 1;                             --
                   end if;
    ----------------------------------------------------------------------------
                when READ_RS =>
    ----------------------------------------------------------------------------
                  data(bitIndex) <= uart_rs;                                    --
                        bitIndex <= bitIndex + 1;                               --
                      state_uart <= WAIT_RS;                                    --
    ----------------------------------------------------------------------------
                when WAIT_RS =>
    ----------------------------------------------------------------------------
                   if (timer_uart = baud_ref) then                              --
                      timer_uart <= RESET_INT;                                  --
                      state_uart <= READ_RS;                                    --
                  elsif (bitIndex = bit_max_ref) then                           --
                      state_uart <= CHECK_RS;                                   --
                    else
                      timer_uart <= timer_uart + 1;                             --
                    end if;
    ----------------------------------------------------------------------------
                when CHECK_RS =>
    ----------------------------------------------------------------------------
                    if (rsData(0) = LOW) and (rsData(10) = HIGH) and (state_parity = INIT_PAR) then
                          parity <= rsData(8) xor rsData(7) xor rsData(6) xor rsData(5) xor rsData(4) xor rsData(3) xor rsData(2) xor rsData(1);
                    state_parity <= DONE_PAR;                                   -- PARITY IS CALCULATED
              elsif (state_parity = DONE_PAR) then
                       if (parity = rsData(9)) then
                      state_uart <= CHECK_RS;                                   -- PARITY went right
                       else
                     parity_fail <= HIGH;                                       -- SET BIT HIGH
                      state_uart <= WAIT_RS;                                    -- PARITY IS WRONG!!!!! ERROR!!
                       end if;
                    else
                       sync_fail <= HIGH;                                       -- SET BIT HIGH
                      state_uart <= WAIT_RS;                                    -- ERROR OCCURED!!!!!
                    end if;
    ----------------------------------------------------------------------------
                when CHECK_RS =>
    ----------------------------------------------------------------------------
                            data <= rsData(8 downto 1);                         -- DATA IS OUT
                           ready <= HIGH;                                       -- MADE READY TO READ
                      state_uart <= WAIT_RS;                                    --
    ----------------------------------------------------------------------------
                when others =>
    ----------------------------------------------------------------------------
                     state_uart <= WAIT_RS;                                     -- IF SOMETHING WENT WRONG
            end case;
        end if;
    end process;
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
end Behavioral;
