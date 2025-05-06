--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        btnL    :   in std_logic; -- clk reset
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
      signal slow_clk: std_logic :='0';
      signal tdm_clk: std_logic :='0';
      signal master_reset, clk_reset, fsm_reset : std_logic := '0';
      signal f_data: STD_LOGIC_VECTOR (3 downto 0):="0000";
      signal fsm_cycle : std_logic_vector(3 downto 0);
      signal sig_A: std_logic_vector(7 downto 0);
      signal sig_B: std_logic_vector(7 downto 0);
      signal sig_op: std_logic_vector(2 downto 0);
      signal sig_result:  std_logic_vector(7 downto 0);
      signal sig_flag: std_logic_vector(3 downto 0);
      signal sig_sign: std_logic;
      signal sig_hund: std_logic_vector(3 downto 0);
      signal sig_tens: std_logic_vector(3 downto 0);
      signal sig_ones: std_logic_vector(3 downto 0);
      signal f_sel_n: STD_LOGIC_VECTOR (3 downto 0):="0000";
      
	-- declare components and signals
component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenseg_decoder;
component TDM4 is
		generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	   );
    end component TDM4;
    
    	component clock_divider is
        generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
                                                   -- Effectively, you divide the clk double this 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port ( 	i_clk    : in std_logic;
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic		   -- divided (slow) clock
        );
    end component clock_divider;
 component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end component controller_fsm;

component ALU is
    Port ( i_reset : in STD_LOGIC;
    i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end component ALU;
  
component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
end component twos_comp;
begin
	-- PORT MAPS ----------------------------------------
	    clk_div: clock_divider 
        generic map ( k_DIV => 25000000 )
        port map (
            i_clk => clk,
            i_reset => clk_reset,
            o_clk => slow_clk
        );
        tdm_clk_div: clock_divider 
        generic map ( k_DIV => 100000 )
        port map (
            i_clk => clk,
            i_reset => clk_reset,
            o_clk => tdm_clk
        );
        cont_fsm: controller_fsm
    port map ( 
            i_reset=>master_reset,
           i_adv =>btnC,
           o_cycle => fsm_cycle
           );
           A_L_U: ALU 
    port map ( 
           i_reset=>master_reset,
           i_A=>sig_A,
           i_B =>sig_B,
           i_op =>sig_op,
           o_result =>sig_result,
           o_flags =>sig_flag
           );
           two_comp: twos_comp
    port map(
        i_bin => sig_result,
        o_sign=>sig_sign,
        o_hund=>sig_hund,
        o_tens=>sig_tens,
        o_ones=>sig_ones
    );
    utt_TDM4_inst : TDM4 
	generic map ( k_WIDTH => 4 )
	port map ( 
       i_clk=>tdm_clk,
       i_reset => master_reset,
       i_D3=> "0000",
       i_D2=> sig_hund,
       i_D1=> sig_tens,
       i_D0=> sig_ones,
       o_data=> f_data,
       o_sel=> f_sel_n
	);
	sevenseg_decoder_utt : sevenseg_decoder port map(
	i_Hex=>f_data,
	o_seg_n =>seg
	);
	
	-- CONCURRENT STATEMENTS ----------------------------
	master_reset<=btnU;
	clk_reset<=btnL or master_reset;
	an <= f_sel_n;
	led(15 downto 12) <= sig_flag;
	led(3 downto 0)<=fsm_cycle;
	sig_op <= sw(2 downto 0);
	sig_A<=sw(7 downto 0);
	sig_B<=sw(7 downto 0);
	
	
end top_basys3_arch;
