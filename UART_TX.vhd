----------------------------------------------------------------------------------
-- Company: SDU - TEK
-- Engineer: Daniel Tofte Schøn
--
-- Create Date: 03/03/2019 02:57:58 PM
-- Design Name:
-- Module Name: UART_TX_topmodule - Behavioral
-- Project Name: PANTILT SYSTEM
-- Target Devices: BASYS 3
-- Tool Versions: Vivado 2018.3
-- Description: A UART transmitter module, even parity 1 stop and 1 stat bit.
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
use IEEE.std_logic_arith.ALL;

entity UART_TX is
generic(
    baud        :   integer := 9600;        -- baud rate
    clk_board   :   integer := 100000000   -- clk board
    ); -- baud rate
    -- PARITY is included but it is always even
port(
    send        :   in  std_logic;  -- activate signal
    clk         :   in  std_logic;  -- clk output as input
    data        :   in  std_logic_vector (7 downto 0); -- data to be send
    ready       :   out std_logic; -- is ready to sent if high send
    RsTx        :   out std_logic -- IO Tx
    );
end UART_TX;

architecture Behavioral of UART_TX is
    ----------------------------FUNCTIONS---------------------------------------

    ----------------------------CONSTANTS---------------------------------------
    constant baud_ref       :   integer := clk_board/baud;
    constant bit_max_ref    :   integer := 10;
    ----------------------------CODE SIMPLIFYERS--------------------------------
    constant stop_bit       :   std_logic := '1';
    constant start_bit      :   std_logic := '0';
    constant inactive       :   std_logic := '1';
    ----------------------------TYPE--------------------------------------------
    type    state_type is (RDY, LOAD_BIT, SEND_BIT);
    ----------------------------SIGNALS-----------------------------------------
    signal state_uart       :   state_type := RDY;
    signal timer_uart       :   integer := 0;
    signal txData           :   std_logic_vector ((bit_max_ref-1) downto 0);
    signal txBit            :   std_logic := '1';
    signal bitIndex         :   integer range 0 TO bit_max_ref := 0;
    ----------------------------START-------------------------------------------

    begin

    ----------------------------PROCESS-----------------------------------------
    -- input: runs if clk runs                                                --
    -- function : UART transmit to PC or other peripheral                     --
    ----------------------------------------------------------------------------
    process(clk) begin
    if (rising_edge(clk)) then
        case state_uart is
    ----------------------------------------------------------------------------
            when RDY =>                                                 -- waiting to send data
                    if (send = '1') then
                        state_uart <= LOAD_BIT;                         -- change to next state
                        txData <= stop_bit & data & start_bit;
                    end if;
                    timer_uart <= 0;                                    -- this is the clk
                    bitIndex <= 0;                                      -- current bit index;
                    txBit <= inactive;                                  -- keep line high
    ----------------------------------------------------------------------------
            when LOAD_BIT =>
                    state_uart <= SEND_BIT;
                    txBit <= txData(bitIndex);                          --this is what we sent
                    bitIndex <= bitIndex + 1;
    ----------------------------------------------------------------------------
            when SEND_BIT =>
                    if (timer_uart = baud_ref) then
                    timer_uart <= 0;                                    --reset when equal to baud_ref
                        if (bitIndex = bit_max_ref) then
                            state_uart <= RDY;                          -- stop when all sent
                        else
                            state_uart <= LOAD_BIT;
                        end if;
                    else
                        timer_uart <= timer_uart + 1;
                    end if;
    ----------------------------------------------------------------------------
            when others =>
                    state_uart <= RDY;
            end case;
        end if;
    end process;
    ----------------------------------------------------------------------------
    RsTx <= txBit;
    ready <= '1' when (state_uart = RDY) else '0';
    ----------------------------------------------------------------------------
end Behavioral;
