
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
  port (clk : in std_logic;             -- The clock signal.
    reset : in  std_logic;              -- Reset the module.
    req   : in  std_logic;              -- Input operand / start computation.
    AB    : in  unsigned(15 downto 0);  -- The two operands.
    ack   : out std_logic;              -- Computation is complete.
    C     : out unsigned(15 downto 0)); -- The result.
end gcd;

architecture fsmd_optimised of gcd is

  type state_type is (State_0,State_1,State_1_A,State_2,State_2_B,State_3,State_4,State_5 ); -- Input your own state names

  signal reg_a, next_reg_a, next_reg_b, reg_b : unsigned(15 downto 0);

  signal state, next_state : state_type;


begin
  cl : process (req,ab,state,reg_a,next_reg_a,reg_b,reset)
  begin
        ack <= '0';
        C   <= (others => '0');
        next_reg_a <= reg_a;
        next_reg_b <= reg_b;
        next_state <= state ;

    case (state) is
        when State_0 =>     
                if(req = '0') then
                        next_state <= State_0;
                else
                        next_state <= State_1;
                end if;

        when State_1 =>                                        -- takes A
                next_reg_a <= AB;
                ack <= '1' ;
                next_state <= State_1_A;         

        when State_1_A => 
                 ack <= '0' ;  
                 next_state <= State_2;

        when State_2 =>
                if (req = '1') then                          
                        next_state <= State_2_B;
                else
                        next_state <= State_2;          
                end if;
    
        when State_2_B =>
                next_reg_b <= AB;                      
                next_state <= State_3;                   

        when State_3 =>
                if(reg_a > reg_b) then
                        next_state <= State_4;
                elsif(reg_a < reg_b) then
                        next_state <= State_5;
                elsif(reg_a = reg_b) then
                        ack <= '1'  ;         
                        C <= reg_a  ;   
                        if (req = '0') then      
                            ack <= '0';
                            next_state <= State_0; 
                        else
                            next_state <= State_3;
                        end if; 
                end if;

        when State_4 => 
                next_reg_a <= reg_a - reg_b;
                next_state <= State_3;
              
        when State_5 => 
                next_reg_b <= reg_b - reg_a;
                next_state <= State_3;  
end case;
end process cl;


  seq : process (clk, reset)
  begin 
    if(reset = '1') then 
        state  <= State_0;
        reg_a <= (others => '0');
        reg_b  <= (others => '0');
    elsif (rising_edge(clk)) then
        state <= next_state;
        reg_a <= next_reg_a;
        reg_b <= next_reg_b;
    end if;
  end process seq;


end fsmd_optimised;
