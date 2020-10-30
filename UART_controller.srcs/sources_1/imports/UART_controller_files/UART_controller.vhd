
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UART_controller is

    port(
        clk              : in  std_logic;
        reset            : in  std_logic;
        tx_enable        : in  std_logic;

        data_in          : in  std_logic_vector (7 downto 0);
        data_out         : out std_logic_vector (7 downto 0);

        rx               : in  std_logic;
        tx               : out std_logic
        );
end UART_controller;


architecture Behavioral of UART_controller is

    component button_debounce
        port(
            clk        : in  std_logic;
            reset      : in  std_logic;
            button_in  : in  std_logic;
            button_out : out std_logic
            );
    end component;


    component UART
        port(
            clk            : in  std_logic;
            reset          : in  std_logic;
            tx_start       : in  std_logic;

            data_in        : in  std_logic_vector (7 downto 0);
            data_out       : out std_logic_vector (7 downto 0);

            rx             : in  std_logic;
            tx             : out std_logic
            );
    end component;

    signal button_pressed : std_logic;

begin

    tx_button_controller: button_debounce
    port map(
            clk            => clk,
            reset          => reset,
            button_in      => tx_enable,
            button_out     => button_pressed
            );

    UART_transceiver: UART
    port map(
            clk            => clk,
            reset          => reset,
            tx_start       => button_pressed,
            data_in        => data_in,
            data_out       => data_out,
            rx             => rx,
            tx             => tx
            );

end Behavioral;
