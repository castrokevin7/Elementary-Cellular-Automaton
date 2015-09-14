-- This program was created by Kevin Castro @kedac007.
-- Escuela de Ingeniería en Computación.
-- Instituto Tecnológico de Costa Rica.

-- Ada Libraries.
with Ada.Text_IO, Ada.Integer_Text_IO; use Ada.Text_IO, Ada.Integer_Text_IO;

-- My Libraries
with My_Types, Bitmap; use My_Types, Bitmap;

procedure Cellular_Automaton is

    -- Procedure and functions declaration.
    function Pattern_Result return MY_BIT;
    procedure Set_Configuration; 
    procedure Initialize_Sequence(N : in INTEGER); 
    procedure Update_Sequence(I : in INTEGER; Image_Width : in INTEGER; Color : in PIXEL); 

    -- Variables declaration
    T             : INTEGER;        -- Time T which defines the amount of states and the bitmap dimensions.
    N             : INTEGER;        -- Number N to define the configuration.
    N_Byte        : MY_BYTE;        -- Byte.
    N_Triad       : MY_TRIAD;       -- Triad.

    -- Image properties.
    Image_Height : INTEGER;
    Image_Width  : INTEGER;
    Color : PIXEL;

    -- Useful pointers declaration.                
    -- Configuration patterns.
    First_Pattern : PATTERN_POINTER;
    Last_Pattern  : PATTERN_POINTER;
    Temp_Pattern  : PATTERN_POINTER;
    -- Sequence Automatas.
    First_Automata : AUTOMATA_POINTER;
    Last_Automata  : AUTOMATA_POINTER;
    Temp_Automata  : AUTOMATA_POINTER;

    -- Create the specific pattern's configuration.
    procedure Set_Configuration is
    begin       
        N_To_Byte(N, N_Byte);                           -- Decimal N to Byte.
        for Pattern_Num in 0..7 loop                    -- From 000 to 111.
            Temp_Pattern := new PATTERN_RECORD;            -- New Pattern - Configuration. 
            N_to_Triad(Pattern_Num, N_Triad);           -- Decimal to Binary (Triad).
            Temp_Pattern.Triad := N_Triad;              -- Setting the triad.
            Temp_Pattern.Bit := N_Byte(Pattern_Num);  
            if First_Pattern = null then
                First_Pattern := Temp_Pattern;
                Last_Pattern := Temp_Pattern;
            else                
                Last_Pattern.Next := Temp_Pattern;
                Last_Pattern := Temp_Pattern;  
            end if;            
        end loop;         
    end Set_Configuration;      

    -- Initializate the N Automatas sequence, from i = 0..(N - 1).
    procedure Initialize_Sequence(N : in INTEGER) is        
    begin
        for I in 0..(N - 1)  loop                       -- Setting the required Automatas.
            Temp_Automata := New AUTOMATA_RECORD;
            if I = (N - 1) / 2 then                     -- Bit on.
                Temp_Automata.Bit := 1;
                Set_Pixel(Image_Width, 0, I, WHITE);    -- Image drawing.
            else
                Temp_Automata.Bit := 0;
            end if;

            if First_Automata = null then                    
                First_Automata := Temp_Automata;
                Last_Automata := Temp_Automata;
            else                                        -- Previous and Next automata declarations.
                Last_Automata.Next := Temp_Automata;
                Temp_Automata.Previous := Last_Automata;
                Last_Automata := Temp_Automata;    
            end if;
        end loop;        
    end Initialize_Sequence;

    -- Develope the state of the Automatas according to the Configuration.
    procedure Update_Sequence(I : in INTEGER; Image_Width : in INTEGER; Color : in PIXEL) is

        Stored_Bit : MY_BIT;							-- Backup bit.

    begin
        Temp_Automata := First_Automata;
        Stored_Bit := Temp_Automata.Bit;
        for J in 0..(Image_Width - 1)  loop             -- Evaluating Ai-1, Ai, Ai+1. i = 0..(2T - 1).
														-- Special cases: First and Last automata.
            if Temp_Automata.Previous = null or Temp_Automata.Next = null then
                if First_Pattern.Bit = 1 and Last_Pattern.Bit = 0 then
                    Temp_Automata.Bit := not Temp_Automata.Bit;
                end if;  
                if Last_Pattern.Bit = 1 then
                    if First_Pattern.Bit = 0 then
                        Temp_Automata.Bit := 0;    
                    else       
                        Temp_Automata.Bit := 1; 
                    end if;
                end if;                          
            else                                        -- Common cases.
                N_Triad(2) := Stored_Bit;				-- Setting the triad.
                N_Triad(1) := Temp_Automata.Bit;
                N_Triad(0) := Temp_Automata.Next.Bit;
                Stored_Bit := Temp_Automata.Bit;
                Temp_Automata.Bit := Pattern_Result;	-- Getting the bit result.
            end if;			
			if Temp_Automata.Bit = 1 then
				Set_Pixel(Image_Width, I, J, Color);	-- Image drawing.	
			end if;			
            Temp_Automata := Temp_Automata.Next;
        end loop;        
    end Update_Sequence;

    -- Returns the bit related to a specific triad that belongs to the configuration.
    function Pattern_Result return MY_BIT is         
    begin
        Temp_Pattern := First_Pattern;   
        while Temp_Pattern.Triad /= N_Triad loop    -- Looking for the equivalet triad.
            Temp_Pattern := Temp_Pattern.Next;
        end loop;
        return Temp_Pattern.Bit;                    -- Returns the result bit.
    end Pattern_Result;      

begin
<<Get_T>>
    Put("Type T: "); Get(T);                        -- Data input: Time T.
    if T < 0 then 
        Put_Line("T should be greater than 0.");
        goto Get_T;
    end if;
<<Get_N>>
    Put("Type N: "); Get(N);                        -- Data input: Number N.
    if N < 0 or N > 255 then
        Put_Line("N should be between 0 and 255.");
        goto Get_N;
    end if; 
   
    Image_Height := T;
    Image_Width := 2 * T;
    Generate_Image(Image_Height * Image_Width);     
    Initialize_Sequence(Image_Width);  
    Set_Configuration;  
    Color := Generate_Pixel;
Main_Loop:
    for I in 1..(Image_Height - 1) loop
        if I + 1 = Image_Height then
            Update_Sequence(I, Image_Width, Color); 
            Export_PPM(Image_Height, Image_Width);
            Put_Line("PPM generated successfully.");
            exit Main_Loop;
        else
            Update_Sequence(I, Image_Width, Color); 
        end if;
    end loop Main_Loop;

exception
    when Data_Error => Put_Line("Data Entry - Error");
                     Put("Program execution finished.");     
end Cellular_Automaton;