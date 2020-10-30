
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity UART_controller_tb is
--  Port ( );
end UART_controller_tb;

architecture Behavioral of UART_controller_tb is


    component UART_controller
        port(
            clk            : in  std_logic;
            reset          : in  std_logic;
            tx_enable      : in  std_logic;

            data_in        : in  std_logic_vector (7 downto 0);
            data_out       : out std_logic_vector (7 downto 0);

            rx             : in  std_logic;
            tx             : out std_logic
            );
    end component;



    signal clk            : std_logic := '0';
    signal reset          : std_logic := '0';
    signal tx_start       : std_logic := '0';

    signal tx_data_in     : std_logic_vector (7 downto 0) := (others => '0');
    signal rx_data_out    : std_logic_vector (7 downto 0) := (others => '0');

    signal tx_serial_out  : std_logic := '1';
    signal rx_serial_in   : std_logic := '1';


    constant clock_cycle : time := 10 ns;    -- 1/clk (1 / 100 000 000)

begin

    uut: UART_controller
    port map(
            clk       => clk,
            reset     => reset,
            tx_enable => tx_start,

            data_in   => tx_data_in,
            data_out  => rx_data_out,

            tx        => tx_serial_out,
            rx        => rx_serial_in
            );


    rx_serial_in <= tx_serial_out;


    clk_generator: process
    begin
        wait for clock_cycle/2;
            clk <= '1';
        wait for clock_cycle/2;
            clk <= '0';
    end process clk_generator;


    signals_generator: process
    begin
        tx_data_in <= X"55";
        tx_start <= '0';

        wait for 25 us;
            tx_start <= '1';
        wait for 110 us;    -- test the button_debounce module
            tx_start <= '0';
        wait for 205 us;

        tx_data_in <= X"FF";

        wait for 28 us;
            tx_start <= '1';
        wait for 110 us;
            tx_start <= '0';
        wait for 200 us;

    end process signals_generator;


end Behavioral;
