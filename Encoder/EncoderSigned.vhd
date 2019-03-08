
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Debounce is
    Port ( clk : in  STD_LOGIC;
           Ain : in  STD_LOGIC; 
           Bin : in  STD_LOGIC;
		   Aout: out STD_LOGIC;
		   Bout: out STD_LOGIC
			  );
end Debounce;

architecture Behavioral of Debounce is

signal sclk: std_logic_vector (6 downto 0);
signal sampledA, sampledB : std_logic_vector (3 downto 0);
begin

	process(clk)
		begin 
			if rising_edge(clk) then
				if sclk = "1100100" then --Sættes til 1 mhz  (100 mhz / 100)
				
                    SampledA(3 downto 1) <= SampledA(2 downto 0);
                    SampledA(0) <= Ain;
                    
                    SampledB(3 downto 1) <= SampledB(2 downto 0);
                    SampledB(0) <= Bin;
                    
					if (SampledA = (SampledA'range => '0')) then 
						Aout <= Ain;
                    elsif (SampledA = (SampledA'range => '1')) then 
                        Aout <= Ain;
                    elsif (SampledB = (SampledB'range => '0')) then 
                        Bout <= Bin;
                    elsif (SampledB = (SampledB'range => '1')) then 
                        Bout <= Bin;
					end if;
					sclk <="0000000";
				else
					sclk <= sclk +1;
				end if;
			end if;
	end process;
	
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Encoder is
		Port (
					clk: in STD_LOGIC;
					A : in  STD_LOGIC;                       
					B : in  STD_LOGIC;
					EncOut: inout STD_LOGIC_VECTOR (7 downto 0) ;
					LED: out STD_LOGIC_VECTOR (15 downto 0)

			  );
end Encoder;

architecture Behavioral of Encoder is

                 -- 00  , 01, 11, 10, 10 ,  11,  01,   c,  cc;
type stateType is ( idle, C1, C2, C3, CC1, CC2, CC3, add, sub);
signal curState, nextState: stateType;

begin

    process (clk)

    begin

		  if rising_edge(clk) then
		  
				if curState /= nextState then
				
					if (curState = add) then
					
					    --hvis værdien er nået max: 127 sættes den tilbage til 0
					    if (EncOut = "01111111") then
					                                    
					            EncOut <= "00000000" ;
					            
                        -- hvis værdien før var -1 sættes den til 0
                        elsif (EncOut = "11111111") then
                        
                                EncOut <= "00000000" ;
                                
                        --I andre tilfælde lægges der en til    
                        else
                        
                                EncOut <= EncOut+1;
                            
                        end if;
                        
                        
					elsif (curState = sub) then
					    
					    --Hvis værdien før var 0 sættes den til -1
                        if (EncOut = "00000000") then
                        
                                EncOut <= "11111111";
                        
                        --Hvis Værdien var nået min: -127 sættes den tilbae til 0
                        elsif (EncOut = "10000000") then
                         
                                EncOut <= "00000000";
                               
                        --I andre tilfælde trækkes der en fra 
                        else
                         
                                EncOut <= EncOut-1;
                                
                        end if;

					end if;
					 
				end if;
			--CurState opdateres for at kunne holde styr på om nextState ændres
            curState <= nextState;
        end if;
        
        --Til debugg viser værdien af EncOut
        led (7 downto 0) <= EncOut;
    end process; 


    state: process (curState, A, B)
	
    begin
			case curState is
			
			--Starter i idel, returnere ved skift fra c to cc
            when idle =>
                     
                     --Afhængigt af hvilken værdi startes der på en ny retning
					 if B = '0' then
                        nextState <= C1;
					 elsif A = '0' then
						nextState <= CC1;
					 else
						nextState <= idle;
                end if;
            
            
            when C1 =>
                    
					if B='1' then
                        nextState <= idle;
                    elsif A = '0' then
                        nextState <= C2;
					else
						nextState <= C1;
               end if;	
               				
            when C2 =>
            		
					if A ='1' then
                        nextState <= C1;
                    elsif B = '1' then
                        nextState <= C3;
					else
						nextState <= C2;
               end if;
               
			when C3 =>

					if B ='0' then
                  nextState <= C2;
               elsif A = '1' then
                  nextState <= add;
                  led(15) <= '1';
					else
						nextState <= C3;
               end if;
               
		     when add =>

					nextState <= idle;

			 when CC1 =>
				
					if A ='1' then
                  nextState <= idle;
               elsif B = '0' then
                  nextState <= CC2;
					else
						nextState <= CC1;
               end if;
               	
			 when CC2 =>

					if B ='1' then
                  nextState <= CC1;
               elsif A = '1' then
                  nextState <= CC3;
					else
						nextState <= CC2;
               end if;
               
		     when CC3 =>

					if A ='0' then
                  nextState <= CC2;
               elsif B = '1' then
                  nextState <= sub;
                  led(15) <= '0';
					else
						nextState <= CC3;
               end if;	
					
		     when others =>
		     
					nextState <= idle;
					
        end case;
	end process; 	

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity PmodENC is
    Port (
			 clk: in std_logic;
             JA : in STD_LOGIC_VECTOR (7 downto 4); 
			 led: out STD_LOGIC_VECTOR (15 downto 0)

			  );
end PmodENC;



architecture Behavioral of PmodENC is
component Debounce is
	port(
			clk : in  STD_LOGIC;
            Ain : in  STD_LOGIC;
            Bin : in  STD_LOGIC;
			Aout: out STD_LOGIC;
			Bout: out STD_LOGIC
		);
	end component;

component Encoder is
	Port (
					clk: in STD_LOGIC;
					A : in  STD_LOGIC;
					B : in  STD_LOGIC;
					EncOut: inout STD_LOGIC_VECTOR (7 downto 0);
					LED: out STD_LOGIC_VECTOR (15 downto 0)
			  );
	end component;
	
signal EncO : std_logic_vector (7 downto 0) := "00000000" ;
signal AO, BO: std_logic;

begin

	C0: Debounce port map ( clk=>clk, Ain=>JA(4), Bin=>JA(5), Aout=> AO, Bout=> BO);
	C1: Encoder port map ( clk=>clk, A=>AO, B=>BO, EncOut=>EncO, LED=>led);
	
end Behavioral;

