----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/04/2019 11:27:16 PM
-- Design Name:
-- Module Name: SPI_topmodule - Behavioral
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

entity SPI_topmodule is
generic(
    data_l      :   integer := 16
    );
port(
    sck         :   in  std_logic := '0';
    ss          :   in  std_logic := '0';
    mosi        :   in  std_logic := '0';
    miso        :   out std_logic := '0';
    data_out    :   out std_logic_vector(data_l-1 downto 0);
    data_in     :   in std_logic_vector(data_l-1 downto 0);
    busy        :   out std_logic := '0';
    ready       :   out std_logic := '0'
    );
end SPI_topmodule;

architecture Behavioral of SPI_topmodule is
--------------------------------------------------------------------------------

    component SPI_slave_reciever
    generic(
        data_l : integer := 16
        );
    port(
        sck     :   in  std_logic;
        ss      :   in  std_logic;
        mosi    :   in  std_logic;
        data    :   out std_logic_vector(data_l-1 downto 0);
        busy    :   out std_logic;
        ready   :   out std_logic
        );
    end component;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

    component SPI_slave_trns
    generic(
        data_l  :   integer := 16
        );
    port(
        sck     :   in  std_logic;
        ss      :   in  std_logic;
        data    :   in  std_logic_vector(data_l-1 downto 0);
        miso    :   out std_logic;
        busy    :   out std_logic
        );
    end component;

--------------------------------------------------------------------------------

    signal b_busy_reci : std_logic;
    signal b_busy_trns : std_logic;
    signal b_data_out  : std_logic_vector(data_l-1 downto 0);
    signal b_data_in   : std_logic_vector(data_l-1 downto 0);


--------------------------------------------------------------------------------

begin

    busy <= b_busy_reci or b_busy_trns;
    data_out <= b_data_out;
    b_data_in <= data_in;


    -- IMPLEMENT PROTOCOL
    -- IF DATA IS ADRESS "0001 send frame to PWM1 -- first check checksum!"




RECI: SPI_slave_reciever
    generic map(data_l => data_l)
    port map(sck => sck, ss => ss, mosi => mosi, data => b_data_out, busy => b_busy_reci, ready => ready);

TRNS: SPI_slave_trns
    generic map(data_l => data_l)
    port map(sck => sck, ss => ss, data => b_data_in, miso => miso, busy => b_busy_trns);


end Behavioral;
