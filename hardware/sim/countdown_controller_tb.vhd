library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_controller_tb is end entity;
architecture test of countdown_controller_tb is
    signal clock : std_logic := '0';
    signal resetn : std_logic := '0';
    signal load_s, start_s, pause_s, reset_s : std_logic := '0';
    signal running, done, reload_s, decrement, tick : std_logic;
    signal remaining, loaded, load_value : std_logic_vector(15 downto 0) := (others => '0');
    signal divider : natural range 0 to 3 := 0;
    signal finished : boolean := false;
begin
    clock <= not clock after 5 ns when not finished else '0';
    dut: entity work.countdown_controller
        port map (clock, resetn, load_s, start_s, pause_s, reset_s,
                  remaining, tick, running, done, reload_s, decrement);

    -- Behavioral core model only. A due tick is retained if a command
    -- suppresses its consumption, including PAUSE on the terminal count.
    tick <= '1' when running = '1' and divider = 3 else '0';
    process(clock, resetn)
    begin
        if resetn = '0' then
            remaining <= (others => '0'); loaded <= (others => '0'); divider <= 0;
        elsif rising_edge(clock) then
            if load_s = '1' then
                remaining <= load_value; loaded <= load_value; divider <= 0;
            elsif reload_s = '1' then
                remaining <= loaded; divider <= 0;
            elsif running = '1' then
                if divider = 3 then
                    if decrement = '1' then divider <= 0; end if;
                else
                    divider <= divider + 1;
                end if;
                if decrement = '1' then
                    assert unsigned(remaining) > 0 report "underflow request" severity failure;
                    remaining <= std_logic_vector(unsigned(remaining) - 1);
                end if;
            end if;
        end if;
    end process;

    stimulus: process
        procedure step is
        begin wait until rising_edge(clock); wait for 1 ns; end procedure;
        procedure idle(n : positive := 1) is
        begin for i in 1 to n loop step; end loop; end procedure;
        procedure check(value : natural; r, d : std_logic; label_text : string) is
        begin
            assert unsigned(remaining) = value and running = r and done = d
                report label_text severity failure;
        end procedure;
        procedure load_duration(value : natural) is
        begin
            load_value <= std_logic_vector(to_unsigned(value, 16)); load_s <= '1';
            step; load_s <= '0'; wait for 1 ns;
            check(value, '0', '0', "LOAD must pause and clear DONE");
        end procedure;
        procedure command(signal s : out std_logic) is
        begin s <= '1'; step; s <= '0'; wait for 1 ns; end procedure;
    begin
        wait for 1 ns;
        check(0, '0', '0', "hardware reset");
        assert decrement = '0' and reload_s = '0' severity failure;
        resetn <= '1'; step;
        load_duration(3);
        idle(6); check(3, '0', '0', "paused timer changed");
        command(start_s); check(3, '1', '0', "start");
        idle(2);
        command(pause_s); check(3, '0', '0', "pause before tick");
        assert divider = 3 report "fraction not preserved at pause edge" severity failure;
        idle(6); assert divider = 3 report "paused fraction advanced" severity failure;
        command(pause_s); check(3, '0', '0', "repeated pause");
        command(start_s); check(3, '1', '0', "resume");
        step; check(2, '1', '0', "resume lost fractional tick");
        command(start_s); check(2, '1', '0', "repeated start reloaded");
        assert divider = 1 report "repeated start reset divider" severity failure;
        idle(3); check(1, '1', '0', "second decrement");
        idle(4); check(0, '0', '1', "final decrement and DONE must share edge");
        idle(8); check(0, '0', '1', "DONE not sticky");
        command(pause_s); command(start_s); check(0, '0', '1', "commands cleared DONE");
        command(reset_s); check(3, '0', '0', "reset did not restore loaded duration");
        assert divider = 0 severity failure;

        -- Zero-duration start never requests a decrement.
        load_duration(0); command(start_s); check(0, '0', '1', "zero-duration start");
        idle(4); assert decrement = '0' severity failure;
        load_duration(1); command(start_s); idle(3);
        assert tick = '1' report "expected final tick due" severity failure;
        pause_s <= '1'; wait for 1 ns;
        assert decrement = '0' report "pause must override final tick" severity failure;
        step; pause_s <= '0'; wait for 1 ns;
        check(1, '0', '0', "pause consumed final tick");
        idle(3); command(start_s); step; check(0, '0', '1', "pending tick lost on resume");

        -- RESET at final tick reloads without expiring.
        load_duration(2); command(start_s); idle(7);
        reset_s <= '1'; wait for 1 ns;
        assert reload_s = '1' and decrement = '0' severity failure;
        step; reset_s <= '0'; wait for 1 ns;
        check(2, '0', '0', "reset/tick priority");

        -- LOAD overrides every other command and a due tick.
        command(start_s); idle(3);
        load_value <= x"0007"; load_s <= '1'; reset_s <= '1'; pause_s <= '1'; start_s <= '1';
        wait for 1 ns;
        assert reload_s = '0' and decrement = '0' report "LOAD priority" severity failure;
        step;
        load_s <= '0'; reset_s <= '0'; pause_s <= '0'; start_s <= '0'; wait for 1 ns;
        check(7, '0', '0', "simultaneous commands");
        command(start_s); idle(3); command(start_s);
        check(7, '1', '0', "repeated START at tick changed remaining");
        assert divider = 3 report "suppressed tick lost" severity failure;
        step; check(6, '1', '0', "suppressed tick not consumed later");

        -- RESET beats PAUSE/START; PAUSE beats START.
        reset_s <= '1'; pause_s <= '1'; start_s <= '1'; step;
        reset_s <= '0'; pause_s <= '0'; start_s <= '0'; wait for 1 ns;
        check(7, '0', '0', "RESET priority");
        command(start_s); pause_s <= '1'; start_s <= '1'; step;
        pause_s <= '0'; start_s <= '0'; wait for 1 ns;
        check(7, '0', '0', "PAUSE priority");

        -- Full 16-bit unsigned value and asynchronous reset while running.
        load_duration(65535); command(start_s); idle(4);
        check(65534, '1', '0', "unsigned range");
        resetn <= '0'; start_s <= '1'; reset_s <= '1'; wait for 1 ns;
        check(0, '0', '0', "asynchronous reset while running");
        assert reload_s = '0' and decrement = '0' report "reset output gating" severity failure;
        start_s <= '0'; reset_s <= '0'; resetn <= '1'; step;
        check(0, '0', '0', "reset release");
        report "PASS: countdown controller scenarios" severity note;
        finished <= true;
        wait;
    end process;
    watchdog: process
    begin
        wait for 20 us;
        assert finished report "testbench timed out" severity failure;
        wait;
    end process;
end architecture;
