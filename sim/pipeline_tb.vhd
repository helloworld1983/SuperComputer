library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.common.all;

entity pipeline_tb is
--  Port ( );
end pipeline_tb;

architecture Behavioral of pipeline_tb is

    component pipeline
         Port (
         rst : in std_logic;
             clk : in std_logic;
             iaddr : out std_logic_vector(15 downto 0);
             iread : in std_logic_vector(15 downto 0);
             daddr : out std_logic_vector(15 downto 0);
             dwen : out std_logic;
             dwrite : out std_logic_vector(15 downto 0);
             dread : in std_logic_vector(15 downto 0)
         );
    end component;
    
    type word_array is array(0 to 50) of std_logic_vector(15 downto 0);
    
    signal instr_memory: word_array  := (
        0 => (others => '0'), -- nop
        1 => "0010010" & "0" & x"02", -- loadimm lower with 0x07
        -- five nops to clear the pipeline
        6 => "0010010" & "1" & x"05", -- loadimm upper with 0xff
        -- five nops to clear the pipeline
        11 => "0010011" & "000" & "111" & "000", -- mov R0, R7
        -- five nops to clear the pipeline
        16 => "0010010" & "1" & x"00", -- loadimm upper with 0x00
        -- five nops to clear the pipeline
        21 => "0010011" & "001" & "111" & "000", -- mov R1, R7
        -- five nops to clear the pipeline
        -- R0 = 0x0502, R1 = 0x0002
        26 => "0000001" & "010" & "001" & "000", -- add R2, R1, R0 should be 0x0504
        27 => "0000010" & "011" & "001" & "000", -- sub R3, R1, R0 should be 0xFB00
        28 => "0000011" & "100" & "001" & "000", -- mul R4, R1, R0 should be 0x0A04 (overflowed)
        29 => "0000100" & "101" & "001" & "000", -- nand R5, R1, R0 should be 0xFFFD
        30 => "0000101" & "001" & "00" & "0100", -- shl R1, 4 should be 0x0020
        31 => "0000110" & "000" & "00" & "0010", -- shr R0, 2 should be 0x0140
        others => (others => '0') -- rest are nops
    );

    signal clk, rst: std_logic;
        
    signal iaddr, iread, daddr, dwrite, dread : std_logic_vector(15 downto 0);
    signal dwen: std_logic;

begin

    instr_pipeline: pipeline port map (
    clk => clk,
    rst => rst,
    iaddr => iaddr,
    iread => iread,
    daddr => daddr,
    dwen => dwen,
    dwrite => dwrite,
    dread => dread);
    
    -- clock process
    process begin
        clk <= '0';
        wait for 10 us;
        clk <= '1';
        wait for 10 us;
    end process;
    
    iread <= instr_memory(to_integer(unsigned(iaddr))) when (unsigned(iaddr) < word_array'length) else
             (others => '0');

    process begin
        rst <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        rst <= '0';
        wait;
    end process;

end Behavioral;
