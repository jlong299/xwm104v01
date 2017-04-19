	component lpm_mult_1816_mrd is
		port (
			dataa  : in  std_logic_vector(17 downto 0) := (others => 'X'); -- dataa
			datab  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- datab
			clock  : in  std_logic                     := 'X';             -- clock
			result : out std_logic_vector(33 downto 0)                     -- result
		);
	end component lpm_mult_1816_mrd;

	u0 : component lpm_mult_1816_mrd
		port map (
			dataa  => CONNECTED_TO_dataa,  --  mult_input.dataa
			datab  => CONNECTED_TO_datab,  --            .datab
			clock  => CONNECTED_TO_clock,  --            .clock
			result => CONNECTED_TO_result  -- mult_output.result
		);

