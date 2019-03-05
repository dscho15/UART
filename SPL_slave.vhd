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


entity SPI_slave_transmitter is
generic(
    data_l : integer := 8
    );
port(
    sck     :   in  std_logic;
    ss      :   in  std_logic;
    data    :   in  std_logic_vector(data_l-1 downto 0);
    miso    :   out std_logic;
    busy    :   out std_logic
    );
end SPI_slave_transmitter;

architecture Behavioral of SPI_slave_transmitter is

type    state_type  is  (RDY_SPI, TRANSMIT_SPI, STOP_SPI)

signal state        :   state_type := RDY_SPI;
signal index        :   integer := data_l-1;

begin
process(sck)
begin
    if (falling_edge(sck)) then
        case( state ) is

            when RDY_SPI =>
                if (ss = '0') then
                    miso <= data(index);
                    state <= TRANSMIT_SPI;
                    busy <= '1';
                    index <= index - 1;
                end if;

            when TRANSMIT_SPI =>
                if (index = 0) then
                    state <= STOP_SPI;
                end if;
                miso <= data(index);
                index <= index - 1;

            when STOP_SPI =>
                index <= data_l-1;
                busy <= '0';
                state <= RDY_SPI;

        end case;
    end if;
end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_slave_reciever is
generic(
    data_l : integer := 8
    );
port(
    sck     :   in  std_logic;
    ss      :   in  std_logic;
    mosi    :   in  std_logic;
    data    :   out std_logic_vector(data_l-1 downto 0);
    busy    :   out std_logic;
    ready   :   out std_logic
    );
end SPI_slave_reciever;

architecture Behavioral of SPI_slave_reciever is

type    state_type  is  (RDY_SPI, RECIEVE_SPI, STOP_SPI)

signal state        :   state_type := RDY_SPI;
signal data_temp    :   std_logic_vector (data_l-1 downto 0);
signal index        :   integer := data_l-1;

begin
process(sck)
begin
    if (falling_edge(sck)) then
        case( state ) is
            when RDY_SPI =>
                if (ss = '0') then
                    data_temp(index) <= mosi;
                    index <= index -1;
                end if;

            when RECIEVE_SPI =>
                if (index = 0) then
                    state <= STOP_SPI;
                else
                    index <= index - 1;
                end if;

            when STOP_SPI =>
                busy <= '0';
                ready <= '1';
                data_temp <= (others => '0');
                data <= data_temp;
                index <= data_l-1;
                state <= RDY_SPI;

        end case;
    end if;
end process;





end Behavioral;
