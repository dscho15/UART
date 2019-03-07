----------------------------------------------------------------------------------
-- Company: SDU TEK
-- Engineer: Martin Dong & Daniel
--
-- Create Date: 03/06/2019 08:29:32 AM
-- Design Name:
-- Module Name: SPI_checksum - Behavioral
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
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--------------------------------------------------------------------------------
-- START_IN startes the functionality only if READY
--------------------------------------------------------------------------------
entity SPI_checksum is
generic(
    data_l              :   integer := 16
    );
port(
    clk                 :   in  std_logic;
    data                :   in  std_logic_vector(data_l-1 downto 0);
    start_in            :   in  std_logic := '0';
    ready               :   out std_logic := '1';
    checksum            :   out std_logic_vector(3 downto 0)
);
end SPI_checksum;
-------------------------ARCH STARTS HEREE--------------------------------------
architecture Behavioral of SPI_checksum is
--------------------------------------------------------------------------------
---------------- https://en.wikipedia.org/wiki/BSD_checksum --------------------
--------------------------------------------------------------------------------
    constant bitmask    :   STD_LOGIC_Vector(3 downto 0) := "1111";
--------------------------------------------------------------------------------
    type STATE_CHECKSUM is  (IDLE, SEG1, SEG2, SEG3);
    type STATE_BEG      is  (IDLE, START, DONE);
    type STATE_ITERATOR is  (CIRC, ADDER, B_AND);
--------------------------------------------------------------------------------
    signal state        :   STATE_CHECKSUM := IDLE;
    signal state_begin  :   STATE_BEG      := IDLE;
    signal state_it     :   STATE_ITERATOR := CIRC;
--------------------------------------------------------------------------------
    signal b_checksum   :   std_logic_vector(3 downto 0);
    signal b_segment    :   std_logic_vector(3 downto 0);
    signal b_ready      :   std_logic := '1';
--------------------------------------------------------------------------------
    begin -- start here --------------------------------------------------------
--------------------------------------------------------------------------------
    ready <= b_ready;
--------------------------------------------------------------------------------
---                               MAIN                                       ---
--------------------------------------------------------------------------------

main:process(clk)
    variable b_data : std_logic_vector(data_l-1 downto 0);
    begin
--------------------------------------------------------------------------------
    case( state ) is
--------------------------------------------------------------------------------
        when IDLE =>
--------------------------------------------------------------------------------
        if (b_ready = '1') and (start_in = '1') then
            b_ready <= '0';
            b_data := data;
            state <= SEG1;
            b_checksum <= "0000";
        else
            state_begin <= IDLE;
            state <= IDLE;
        end if;

--------------------------------------------------------------------------------
        when SEG1 =>
--------------------------------------------------------------------------------
        if (state_begin = IDLE) then
            b_segment <= b_data(15 downto 12);
            state_begin <= START;
            state <= SEG1;
        elsif (state_begin = DONE) then
            state_begin <= IDLE;
            state <= SEG2;
        else
            state <= SEG1;
        end if;
        if (state_begin = START) then
            case( state_it ) is
--------------------------------------------------------------------------------
                when CIRC =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <=  b_checksum(0) & b_checksum(3 downto 1);
                state_it <= ADDER;
--------------------------------------------------------------------------------
                when ADDER =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <= std_logic_vector(unsigned(b_checksum) + unsigned(b_segment));
                state_it <= B_AND;
--------------------------------------------------------------------------------
                when B_AND =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <= b_checksum;
                state_begin <= DONE;
                state_it <= CIRC;
            end case;
        end if;

--------------------------------------------------------------------------------
        when SEG2 =>
--------------------------------------------------------------------------------
        if (state_begin = IDLE) then
            b_segment <= b_data(11 downto 8);
            state_begin <= START;
            state <= SEG2;
        elsif (state_begin = DONE) then
            state_begin <= IDLE;
            state <= SEG3;
        else
            state <= SEG2;
        end if;
        if (state_begin = START) then
            case( state_it ) is
--------------------------------------------------------------------------------
                when CIRC =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <=  b_checksum(0) & b_checksum(3 downto 1);
                state_it <= ADDER;
--------------------------------------------------------------------------------
                when ADDER =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <= std_logic_vector(unsigned(b_checksum) + unsigned(b_segment));
                state_it <= B_AND;
--------------------------------------------------------------------------------
                when B_AND =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <= b_checksum;
                state_begin <= DONE;
                state_it <= CIRC;
            end case;
        end if;

--------------------------------------------------------------------------------
        when SEG3 =>
--------------------------------------------------------------------------------
        if (state_begin = IDLE) then
            b_segment <= b_data(7 downto 4);
            state_begin <= START;
            state <= SEG3;
        elsif (state_begin = DONE) then
            checksum <= b_checksum;
            b_ready <= '1';
            state_begin <= IDLE;
            state <= IDLE;
        else
            state <= SEG3;
        end if;

        if (state_begin = START) then
            case( state_it ) is
--------------------------------------------------------------------------------
                when CIRC =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <=  b_checksum(0) & b_checksum(3 downto 1);
                state_it <= ADDER;
--------------------------------------------------------------------------------
                when ADDER =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <= std_logic_vector(unsigned(b_checksum) + unsigned(b_segment));
                state_it <= B_AND;
--------------------------------------------------------------------------------
                when B_AND =>
--------------------------------------------------------------------------------
                b_checksum(3 downto 0) <= b_checksum;
                state_begin <= DONE;
                state_it <= CIRC;
            end case;
        end if;

--------------------------------------------------------------------------------
        when others =>
            state <= IDLE;
--------------------------------------------------------------------------------
    end case;
    end process;
end Behavioral;
