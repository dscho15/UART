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
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_topmodule is
generic(
    data_l                  :   integer := 16
    );
port(
    clk                     :   in  std_logic;
    sck                     :   in  std_logic := '0';
    ss                      :   in  std_logic := '0';
    mosi                    :   in  std_logic := '0';
    data_controller_i       :   in std_logic_vector(data_l-1 downto 0);
    miso                    :   out std_logic := '0';
    data_controller_o       :   out std_logic_vector(data_l-1 downto 0)
    );
end SPI_topmodule;

architecture Behavioral of SPI_topmodule is
--------------------------------------------------------------------------------
    component SPI_slave_reciever
    generic(
        data_l              : integer := 16
        );
    port(
        sck                 :   in  std_logic;
        ss                  :   in  std_logic;
        mosi                :   in  std_logic;
        data                :   out std_logic_vector(data_l-1 downto 0);
        busy                :   out std_logic;
        ready               :   out std_logic
        );
    end component;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    component SPI_slave_trns
    generic(
        data_l              :   integer := 16
        );
    port(
        sck                 :   in  std_logic;
        ss                  :   in  std_logic;
        data                :   in  std_logic_vector(data_l-1 downto 0);
        miso                :   out std_logic;
        busy                :   out std_logic
        );
    end component;

    component SPI_checksum
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
    end component;
--------------------------------------------------------------------------------
    type STATE_MACH is (IDLE, CHECKSUM, TRNS, RECI, WAITING);


    signal state            : STATE_MACH := IDLE;
    signal b_busy           : std_logic;
    signal b_busy_reci      : std_logic;
    signal b_busy_trns      : std_logic;
    signal b_data_out       : std_logic_vector(data_l-1 downto 0);
    signal b_data_in        : std_logic_vector(data_l-1 downto 0);
    signal b_data_trns      : std_logic_vector(data_l-1 downto 0);
    signal b_data_reci      : std_logic_vector(data_l-1 downto 0);

    signal b_check_data     : std_logic_vector(data_l-1 downto 0);
    signal b_start          : std_logic;
    signal b_ready          : std_logic;
    signal b_checksum       : std_logic_vector(3 downto 0);

--------------------------------------------------------------------------------
begin
    b_busy <= b_busy_reci or b_busy_trns;

    process(clk, ss)

    begin
        if(rising_edge(clk)) then
            if (ss = '1') then
                case( state ) is
        ----------------------------------------------------------------------------
                    when IDLE =>
        ----------------------------------------------------------------------------
                        if (b_busy = '0') and (b_ready = '1') then
                            b_data_in <= b_data_reci; -- read from reciever to controller!
                            b_data_out <= data_controller_i; -- read from controller to transmit!
                            state <= CHECKSUM;
                        else
                            state <= IDLE;
                        end if;
        ----------------------------------------------------------------------------
                    when CHECKSUM =>
        ----------------------------------------------------------------------------
                        b_check_data <= b_data_out;
                        b_start <= '1'; -- start checksum
                        state <= TRNS;
        ----------------------------------------------------------------------------
                    when TRNS =>
        ----------------------------------------------------------------------------
                        if (b_start = '0') then
                            if (b_ready = '1') then
                                b_data_trns <= b_check_data(data_l-1 downto 4) & b_checksum(3 downto 0);
                                b_check_data <= b_data_in; -- load data recieved
                                b_start <= '1'; -- start checksum calculator
                                state <= RECI;
                            else
                                state <= TRNS;
                            end if;
                        else
                            b_start <= '0';
                            state <= TRNS;
                        end if;
        ----------------------------------------------------------------------------
                    when RECI =>
        ----------------------------------------------------------------------------
                        if (b_start = '0') then
                            if (b_ready = '1') then
                                if (b_checksum = b_data_in(3 downto 0)) then
                                    data_controller_o <= b_data_in;
                                    state <= WAITING;
                                else
                                    data_controller_o <= x"0000"; -- checksum was wrong
                                    state <= WAITING;
                                end if;
                            else
                                state <= RECI;
                            end if;
                        else
                            b_start <= '0';
                            state <= RECI;
                        end if;
        ----------------------------------------------------------------------------
                    when WAITING => state <= WAITING;
        ----------------------------------------------------------------------------
                end case;
            else
                state <= IDLE;
            end if;
        end if;
    end process;


URECI: SPI_slave_reciever
    generic map(data_l => data_l)
    port map(sck => sck, ss => ss, mosi => mosi, data => b_data_reci, busy => b_busy_reci, ready => b_ready);

UTRNS: SPI_slave_trns
    generic map(data_l => data_l)
    port map(sck => sck, ss => ss, data => b_data_trns, miso => miso, busy => b_busy_trns);

CHK : SPI_checksum
    generic map(data_l => data_l)
    port map(clk => clk, data => b_check_data, start_in => b_start, ready => b_ready, checksum => b_checksum );

end Behavioral;
