	component altmult_complex_18_mrd is
		port (
			dataa_real  : in  std_logic_vector(17 downto 0) := (others => 'X'); -- dataa_real
			dataa_imag  : in  std_logic_vector(17 downto 0) := (others => 'X'); -- dataa_imag
			datab_real  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- datab_real
			datab_imag  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- datab_imag
			clock       : in  std_logic                     := 'X';             -- clk
			result_real : out std_logic_vector(33 downto 0);                    -- result_real
			result_imag : out std_logic_vector(33 downto 0)                     -- result_imag
		);
	end component altmult_complex_18_mrd;

	u0 : component altmult_complex_18_mrd
		port map (
			dataa_real  => CONNECTED_TO_dataa_real,  --  complex_input.dataa_real
			dataa_imag  => CONNECTED_TO_dataa_imag,  --               .dataa_imag
			datab_real  => CONNECTED_TO_datab_real,  --               .datab_real
			datab_imag  => CONNECTED_TO_datab_imag,  --               .datab_imag
			clock       => CONNECTED_TO_clock,       --               .clk
			result_real => CONNECTED_TO_result_real, -- complex_output.result_real
			result_imag => CONNECTED_TO_result_imag  --               .result_imag
		);

