	component mrd_RAM_IP is
		port (
			data      : in  std_logic_vector(35 downto 0) := (others => 'X'); -- datain
			wraddress : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- wraddress
			rdaddress : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- rdaddress
			wren      : in  std_logic                     := 'X';             -- wren
			clock     : in  std_logic                     := 'X';             -- clock
			rden      : in  std_logic                     := 'X';             -- rden
			q         : out std_logic_vector(35 downto 0)                     -- dataout
		);
	end component mrd_RAM_IP;

	u0 : component mrd_RAM_IP
		port map (
			data      => CONNECTED_TO_data,      --  ram_input.datain
			wraddress => CONNECTED_TO_wraddress, --           .wraddress
			rdaddress => CONNECTED_TO_rdaddress, --           .rdaddress
			wren      => CONNECTED_TO_wren,      --           .wren
			clock     => CONNECTED_TO_clock,     --           .clock
			rden      => CONNECTED_TO_rden,      --           .rden
			q         => CONNECTED_TO_q          -- ram_output.dataout
		);

