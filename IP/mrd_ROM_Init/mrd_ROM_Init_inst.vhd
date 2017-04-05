	component mrd_ROM_Init is
		port (
			address : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			clock   : in  std_logic                     := 'X';             -- clk
			q       : out std_logic_vector(63 downto 0)                     -- dataout
		);
	end component mrd_ROM_Init;

	u0 : component mrd_ROM_Init
		port map (
			address => CONNECTED_TO_address, --  rom_input.address
			clock   => CONNECTED_TO_clock,   --           .clk
			q       => CONNECTED_TO_q        -- rom_output.dataout
		);

