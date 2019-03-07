----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/04/2019 07:28:51 PM
-- Design Name:
-- Module Name: SPL_slave - Behavioral
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

entity SPI_slave_reciever is
generic(
    data_l : integer := 16
    );
port(
    sck     :   in  std_logic := '0';
    ss      :   in  std_logic := '1';
    mosi    :   in  std_logic;
    data    :   out std_logic_vector(data_l-1 downto 0) := x"0000";
    busy    :   out std_logic := '0';
    ready   :   out std_logic := '1'
    );
end SPI_slave_reciever;

architecture Behavioral of SPI_slave_reciever is

    type enable_spi is (ENB, DIS, WAITING);
    signal state        :   enable_spi := ENB;

    signal data_temp    :   std_logic_vector (data_l-1 downto 0) := x"0000";
    signal index        :   integer := data_l-1;

begin

process(sck, ss)

    variable b_index : integer;

begin

    case( state ) is

            when ENB =>
            if (ss = '0') then
                busy <= '1';
                index <= data_l-1;
                data_temp <= (others => '0');
                state <= DIS;
                ready <= '0';
            else
                busy <= '0';
                state <= ENB;
            end if;

            when DIS =>
            if (ss = '0') then
                if(rising_edge(sck)) then
                    b_index := index;
                    if (b_index >= 1) then
                        data_temp(index) <= mosi;
                        index <= index - 1;
                        state <= DIS;
                    elsif (b_index = 0) then
                        data_temp(index) <= mosi;
                        state <= WAITING;
                    else
                        data_temp <= x"0000"; -- error
                        state <= WAITING;
                    end if;
                end if;
            else
                data_temp <= x"0000"; -- error
                state <= WAITING;
            end if;

            when WAITING =>
            if(ss = '1') then
                data <= data_temp;
                busy <= '0';
                ready <= '1';
                state <= ENB;
            end if;

        end case;

    end process;
    end Behavioral;
