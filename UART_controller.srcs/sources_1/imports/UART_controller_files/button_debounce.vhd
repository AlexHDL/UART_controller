
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity button_debounce is
    generic (
            COUNTER_SIZE : integer := 10_000
            );
    port ( clk        : in  std_logic;
           reset      : in  std_logic;
           button_in  : in  std_logic;
           button_out : out std_logic);
end button_debounce;



architecture Behavioral of button_debounce is

    signal flipflop_1       : std_logic := '0';     -- output of flip-flop 1
    signal flipflop_2       : std_logic := '0';     -- output of flip-flop 2
    signal flipflop_3       : std_logic := '0';     -- output of flip-flop 3
    signal flipflop_4       : std_logic := '0';     -- output of flip-flop 4
    signal count_start      : std_logic := '0';

begin

-- The input_flipflops process creates two serial flip-flops (flip-flop 1 and
-- flip-flop 2). The signal from button_in passes them one by one. If flip_flop_1
-- and flip_flop_2 are different, it means the button has been activated, and
-- count_start becomes '1' for one master clock cycle.

    input_flipflops: process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                flipflop_1 <= '0';
                flipflop_2 <= '0';
            else
                flipflop_1 <= button_in;
                flipflop_2 <= flipflop_1;
            end if;
        end if;
    end process input_flipflops;


-- The count_start signal triggers the pause_counter process to start counting

    count_start <= flipflop_1 xor flipflop_2;


-- The pause_counter process passes the button_in signal farther from flip-flop 2
-- to flip-flop 3, but after COUNTER_SIZE master clock cycles. This allows
-- the button_in signal to stabilize in a certain state before being passed to the output.

    pause_counter: process(clk)
        variable count: integer range 0 to COUNTER_SIZE := 0;
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                count := 0;
                flipflop_3 <= '0';
            else
                if (count_start = '1') then
                    count := 0;
                elsif (count < COUNTER_SIZE) then
                    count := count + 1;
                else
                    flipflop_3 <= flipflop_2;
                end if;
            end if;
        end if;
    end process pause_counter;


-- the purpose of the output_flipflop process is creating another flip-flop (flip-flop 4),
-- which creates a delay between the flipflop_3 and flipflop_4 signals. The delay is
-- one master clock cycle long.

    output_flipflop: process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                flipflop_4 <= '0';
            else
                flipflop_4 <= flipflop_3;
            end if;
        end if;
    end process output_flipflop;


-- The delay is needed to create one short (one master clock cycle long) impuls
-- at the button_out output. When pause_counter has finished, the flipflop_3 signal gets
-- the button_in information. At the moment flipflop_4 hasn't changed yet.
-- This creates '1' at the button_out output for one master clock cycle, only if
-- flipflop_3 is '1' (The button has been pressed, not released).

    with flipflop_3 select
    button_out <= flipflop_3 xor flipflop_4 when '1',
                  '0'                       when others;


end Behavioral;
