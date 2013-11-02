% Text RPG by Sylvain Sauve

% -- TO DO --
% Overhaul menus
% Dungeons
% Quest System (Quest #1 is done.)
% Mining, Resources and Crafting
% Finish up all 8 playable races, finish the female version as well.

% -- DATA VARIABLES --

import GUI

const version := "Beta 1.5"

var stream, filePosition,                    % These 2 must be declared as integers because they use whole values.
    Selection : int                          % Selection can be declared as anything we want.
var FileName, Extension, FileDir : string    % These 3 will be explained later.

Extension := ".txt"
FileDir := "C:\\"

% Core variables
var x, y, button : int

var w := Window.Open ("graphics:max;max")

var SysFont : int := Font.New ("System:10")
var ComicFont : int := Font.New ("Comic Sans MS:10")
var LargeComicFont : int := Font.New ("Comic Sans MS:20")
var LargeFont : int := Font.New ("Calibri:40")

% -- PICTURE VARIABLES --

var logo : int
var levelPic : int
var charPic : int
var armourPic : int
var weaponPic : int
var BG : int

var btnPic, btnOverPic, btnSmallPic, btnSmallOverPic : int
btnPic := Pic.FileNew ("AssetFiles/others/ButtonNormal.bmp")
btnOverPic := Pic.FileNew ("AssetFiles/others/ButtonOver.bmp")
btnSmallPic := Pic.FileNew ("AssetFiles/others/ButtonNarrow.bmp")
btnSmallOverPic := Pic.FileNew ("AssetFiles/others/ButtonNarrowOver.bmp")

% -- STATS & VARIABLES --

% Character Appearance
var name : string
var gender : string
var race : int % 1 - White Human, 2 - Black Human (African), 3 - Asian Human, 4 - Elf, 5 - Dwarf, 6 - Felina, 7 - Reptilia, 8 - Demon

% Level & XP
var level := 1 % Capped at 40.
var XP := 0
var totalXP := 0
var gold := 0
var storyProgress := 0
var corruption := 50
const minCor := 0
const maxCor := 100
const levelCap := 40

% Stats (HP, MP, Power)
var HP := 10 % Health
var MP := 10 % Mana
var maxHP := 10 % Maximum HP, derived from Level and Constitution.
var maxMP := 10 % Maximum MP, derived from Intelligence.
var PPwr : int := 1 % Physical Power, derived from Strength and Weapon Power.
var MPwr : int := 1 % Magical Power, derived from Intelligence.
var Hunger := 100 % Hunger
const maxHunger := 100

% Attributes (They can go up to 10.)
var STR := 1 % Strength (+1 Physical Power)
var CON := 1 % Constitution (+10 Max HP)
var INT := 1 % Intelligence (+2 Max MP, +10% Spell Power)
var DEX := 1 % Dexterity (+1% Critical Chance, +1% Dodge Chance, +2% Hit Chance)

% Spell Levels (They can go up to 3.)
var Heal := 0
var Fire := 0
var Thunder := 0
var Ice := 0

% Equipment
var weapon := "Fists" % Weapon (You start with fists, which does 1 damage.)
var weaponDamage := 1 % Weapon Damage
var weaponTier := 0 % There are 10 tiers of weapons.
var armour := "Clothes" % Armour (You start with clothes, which has no protection.)
var armourProtection := 0 % Armour Protection, +2.5% protection per point. Capped at 30, which is 75% protection.
var armourTier := 0 % There are 10 tiers of armour.
var accessory := "None" % Accessory

% Items
var HPotion, MPotion := 0 % Tier I Potions
var HPotionII, MPotionII := 0 % Tier II Potions
var HPotionIII, MPotionIII := 0 % Tier III Potions

% Enemy Info
var enemyName : string
var enemyLevel : int
var enemyHP : int
var enemyMP : int
var enemyMaxHP : int
var enemyMaxMP : int
var enemyDamage : int
var enemyXP : int % How much XP you will get for defeating enemy.
var enemyGold : int % How much Gold you will get for defeating enemy.

% Status Effects (Player)
var statusPoison, statusNausea, statusBurn, statusFrozen, statusRegen : boolean
var effectPoison, effectNausea, effectBurn, effectFrozen, effectRegen : int := 0
var remainPoison, remainNausea, remainBurn, remainFrozen, remainRegen : int := 0
var resistPoison, resistNausea, resistBurn, resistFrozen : int := 0
const maxDuration := 9

% Status Effects (Enemy)
var statusPoisonE, statusNauseaE, statusBurnE, statusFrozenE, statusRegenE : boolean
var effectPoisonE, effectNauseaE, effectBurnE, effectFrozenE, effectRegenE : int := 0
var remainPoisonE, remainNauseaE, remainBurnE, remainFrozenE, remainRegenE : int := 0
var resistPoisonE, resistNauseaE, resistBurnE, resistFrozenE : int := 0 % Resistance to status effects.
const maxDurationE := 9


% Misc
var cmd : string
var isOnQuest := false
var keyinput : string (1)
var isEnemyRandom : boolean
var DamageDealt : int
var DamageTaken : int
var CritRoll : int
var EnemyMaxHPRoll : int
var HitRoll : int
var RandEnemy : int
var CountUntilTick := 0
var didAttack : boolean := false
var hasPoints : boolean := false
var soundRoll : int
var isBoss : boolean := false
var canHeal, canFire, canThunder, canIce : boolean := false % Determines if enemy can cast spell
var enemyHealCost, enemyFireCost, enemyThunderCost, enemyIceCost : int
var enemySpellPower : int := 0 % Determines how powerful spell is.
var enemySpellOffset : int := 0 % Roll to modify the base effect. It's in percentage.
var enemyMaxOffset : int := 0 % Determines the maximum percentage.
var enemyChoice : int % Roll between 1 and 100 to determine if enemy will use abilities or use normal attack.
var enemyDidAttack : boolean := false
var isQuitting : boolean := false

var timeOfDay : int % Can be 0-24, determines the time of day.
var day : int % Days passed.

% Dungeon variables.
var dungeonX, dungeonY, dungeonZ : int := 0
var dungeonID : int
var dungeonExitX, dungeonExitY, dungeonExitZ : int
var dungeonSizeX, dungeonSizeZ : int
var canNorth, canSouth, canWest, canEast, canUp, canDown : boolean := true
var canExitDungeon : boolean := false
var isExitingDungeon : boolean := false

% Additional dungeon data for dynamic dungeons.
var unlockedDungeonM1, unlockedDungeonM2, unlockedDungeonM3, unlockedDungeonS1, unlockedDungeonS2, unlockedDungeonS3, unlockedDungeonS4, unlockedDungeonS5 : boolean := false
var bossDoorKey1, bossDoorKey2, bossDoorKey3 : boolean := false
var bossDoorLocked1, bossDoorLocked2, bossDoorLocked3 : boolean := false
var dungeon1Chest1Taken, dungeon2Chest1Taken : boolean := false

% Food, can be eaten to refill hunger and some HP and MP.
var bread, cheese, meat : int := 0

% Choices made in quests. (They will affect the dialogue.)
var choiceQM1 := 0
var choiceQM2 := 0
var choiceQM3 := 0
var choiceQM4 := 0

% Resources, will be added in Beta 1.4.

% Ore resources
%var oreIron, oreSilver, oreGold, oreMithril, oreTitanium, oreDiamond : int := 0

% Ingots
%var ingotIron, oreSilver, ingotGold, ingotMithril, ingotTitanium : int := 0

% Resources from mobs that can be used to craft weapon and armour.
%var bones, chitin, spidersilk, dragonscales, : int


% -- Procedure for Saving & Loading --

procedure SaveFile                           % Start of SaveFile.
    Extension := ".txt"                           % This variable has been defined.
    FileDir := "SaveFiles/"                            % This variable has been defined.
    FileName := name                         % "FileName := Name" FileName will then equal what the End-User entered for their name.
    FileName += Extension                    % "FileName += Extension" Puts FileName and Extension together as 1 word.
    FileDir += FileName                      % "FileDir += FileName" Puts directory before FileName.
    open : stream, FileDir, put, seek        %
    tell : stream, filePosition              %
    put : stream, name                      % Character Name
    put : stream, gender                    % Character Gender
    put : stream, race                      % Character race
    put : stream, level                     % Character Level
    put : stream, XP                        % Character XP
    put : stream, totalXP                   % Total XP of Character
    put : stream, gold                      % Character Gold
    put : stream, storyProgress             % Storyline Progress
    put : stream, STR           % Strength
    put : stream, CON           % Constitution
    put : stream, INT           % Intelligence
    put : stream, DEX           % Dexterity
    put : stream, Heal
    put : stream, Fire
    put : stream, Thunder
    put : stream, Ice
    put : stream, PPwr
    put : stream, MPwr
    put : stream, HP
    put : stream, MP
    put : stream, maxHP
    put : stream, maxMP
    put : stream, Hunger
    put : stream, HPotion
    put : stream, MPotion
    put : stream, HPotionII
    put : stream, MPotionII
    put : stream, HPotionIII
    put : stream, MPotionIII
    put : stream, weapon
    put : stream, weaponDamage
    put : stream, weaponTier
    put : stream, armour
    put : stream, armourProtection
    put : stream, armourTier
    put : stream, accessory
    put : stream, isOnQuest
    put : stream, timeOfDay
    put : stream, day
    put : stream, bread
    put : stream, cheese
    put : stream, meat
    put : stream, corruption
    put : stream, choiceQM1
    put : stream, choiceQM2
    put : stream, choiceQM3
    put : stream, choiceQM4
    seek : stream, filePosition              %
    close : stream                           % When finished saving it closes file. (Required for a stable application)
    put "You have saved!"
end SaveFile                                 % End of SaveFile

procedure LoadFile                           % Start of LoadFile
    loop                                     % Infinite Loop.
        put "What is your name?"             % Asks the End-User what their name is.
        get FileName                         % Gets FileName instead of Name to save memory.
        Extension := ".txt"                   % This variable has been defined.
        FileDir := "SaveFiles/"                    % This variable has been defined.
        FileName += Extension                % "FileName += Extension" Puts FileName and Extension together as 1 word.
        FileDir += FileName                  % "FileDir += FileName" Puts directory before FileName.
        if File.Exists (FileDir) then        % Checks if file exists.
            open : stream, FileDir, get      %
            loop                             % Infinite Loop.
                exit when eof (stream)       % Exits loop when end-of-file.
                get : stream, name          % Sets the variable Name.
                get : stream, gender        % Sets the variable Gender.
                get : stream, race          % Sets the variable race.
                get : stream, level         % Sets the Variable Level.
                get : stream, XP            % Character XP
                get : stream, totalXP       % Total XP of character.
                get : stream, gold          % Total Gold of Character.
                get : stream, storyProgress % Main Story Progress
                get : stream, STR           % Strength
                get : stream, CON           % Constitution
                get : stream, INT           % Intelligence
                get : stream, DEX           % Dexterity
                get : stream, Heal
                get : stream, Fire
                get : stream, Thunder
                get : stream, Ice
                get : stream, PPwr
                get : stream, MPwr
                get : stream, HP
                get : stream, MP
                get : stream, maxHP
                get : stream, maxMP
                get : stream, Hunger
                get : stream, HPotion
                get : stream, MPotion
                get : stream, HPotionII
                get : stream, MPotionII
                get : stream, HPotionIII
                get : stream, MPotionIII
                get : stream, weapon
                get : stream, weaponDamage
                get : stream, weaponTier
                get : stream, armour
                get : stream, armourProtection
                get : stream, armourTier
                get : stream, accessory
                get : stream, isOnQuest
                get : stream, timeOfDay
                get : stream, day
                get : stream, bread
                get : stream, cheese
                get : stream, meat
                get : stream, corruption
                get : stream, choiceQM1
                get : stream, choiceQM2
                get : stream, choiceQM3
                get : stream, choiceQM4
            end loop                         % End Loop.
            close : stream                   % When finished saving it closes file. (Required for a stable application)
            exit                             % Exits loop if load was successful.
        else                                 % If error then it will run;
            put "The file does not exist."   % Bullet-Proofing.
            delay (600)                      % Warns End-User of their error.
        end if                               % Ends the IF-Statement.
    end loop                                 % End Loop.
end LoadFile                                 % End LoadFile

% -- GAME ENGINE --

% Style
drawfillbox (0, 0, maxx, maxy, black)
colourback (black)
colour (white)

% Startup

View.Set ("title:TurCraft " + version + "")

logo := Pic.FileNew ("AssetFiles/others/TurCraftLogo.bmp")
Pic.Draw (logo, 0, maxy - 100, picCopy)

locate (9, 1)
put "Welcome to TurCraft, a text-based RPG by Sylvain Sauve."
put "Version: ", version
put "Now with sounds, 1 complete quest and clickable menus!"
put "Inspired by Minecraft, Corruption of Champions, Final Fantasy and various RPGs!"

% New Game Button
Pic.Draw (btnPic, 25, 10, picCopy)
% Load Game Button
Pic.Draw (btnPic, 250, 10, picCopy)
% Exit Game Button
Pic.Draw (btnPic, 475, 10, picCopy)

loop
    Mouse.Where (x, y, button)
    Pic.Draw (btnPic, 25, 10, picCopy)
    Pic.Draw (btnPic, 250, 10, picCopy)
    Pic.Draw (btnPic, 475, 10, picCopy)
    if x >= 25 and x <= 225 and y >= 10 and y <= 60 then
        Pic.Draw (btnOverPic, 25, 10, picCopy)
    else
        Pic.Draw (btnPic, 25, 10, picCopy)
    end if
    if x >= 250 and x <= 450 and y >= 10 and y <= 60 then
        Pic.Draw (btnOverPic, 250, 10, picCopy)
    else
        Pic.Draw (btnPic, 250, 10, picCopy)
    end if
    if x >= 475 and x <= 675 and y >= 10 and y <= 60 then
        Pic.Draw (btnOverPic, 475, 10, picCopy)
    else
        Pic.Draw (btnPic, 475, 10, picCopy)
    end if
    Font.Draw ("New Game", 37, 23, LargeComicFont, black)
    Font.Draw ("Load Game", 262, 23, LargeComicFont, black)
    Font.Draw ("Exit Game", 487, 23, LargeComicFont, black)
    Font.Draw ("New Game", 35, 25, LargeComicFont, white)
    Font.Draw ("Load Game", 260, 25, LargeComicFont, white)
    Font.Draw ("Exit Game", 485, 25, LargeComicFont, white)
    delay (50)
    exit when button not= 0 and x >= 25 and x <= 225 and y >= 10 and y <= 60
    exit when button not= 0 and x >= 250 and x <= 450 and y >= 10 and y <= 60
    exit when button not= 0 and x >= 475 and x <= 675 and y >= 10 and y <= 60
end loop

if x >= 25 and x <= 225 and y >= 10 and y <= 60 then
    cmd := "New"
end if

if x >= 250 and x <= 450 and y >= 10 and y <= 60 then
    cmd := "Load"
end if

if x >= 475 and x <= 675 and y >= 10 and y <= 60 then
    cmd := "Exit"
end if


colour (00)
if cmd = "New" then
    cls
    put "What is your name?"
    colour (brightgreen)
    get name : *
    colour (white)
    put "What is your gender? (M/F)"
    loop
        colour (brightgreen)
        getch (keyinput)
        exit when keyinput = "M" or keyinput = "m" or keyinput = "F" or keyinput = "f"
    end loop
    if keyinput = "M" or keyinput = "m" then
        gender := "Male"
        colour (9)
        put "Your character will be male."
    elsif keyinput = "F" or keyinput = "f" then
        gender := "Female"
        colour (37)
        put "Your character will be female."
    end if
    put ""
    colour (white)
    put "What race would you like your character to be?"
    put ""
    put "1 - White Human"
    put "2 - Black Human"
    put "3 - Asian Human"
    put "4 - Elf (NYI)"
    put "5 - Dwarf (NYI)"
    put "6 - Felis Sapiens"
    put "7 - Reptilia"
    put "8 - Demon (NYI)"
    loop
        colour (brightgreen)
        getch (keyinput)
        exit when keyinput = intstr (1) or keyinput = intstr (2) or keyinput = intstr (3) % or keyinput = intstr(4)
    end loop

    if keyinput = intstr (1) then    % White Human
        race := 1
        STR := 5
        CON := 5
        INT := 5
        DEX := 5
    elsif keyinput = intstr (2) then % Black Human
        race := 2
        STR := 6
        CON := 5
        INT := 4
        DEX := 5
    elsif keyinput = intstr (3) then % Asian Human
        race := 3
        STR := 4
        CON := 5
        INT := 6
        DEX := 5
    elsif keyinput = intstr (4) then % Elf
        race := 4
        STR := 4
        CON := 4
        INT := 5
        DEX := 7
    elsif keyinput = intstr (5) then % Dwarf
        race := 5
        STR := 7
        CON := 5
        INT := 3
        DEX := 5
    elsif keyinput = intstr (6) then % Felis Sapiens
        race := 6
        STR := 4
        CON := 4
        INT := 5
        DEX := 7
    elsif keyinput = intstr (7) then % Reptilia
        race := 7
        STR := 4
        CON := 4
        INT := 7
        DEX := 5
    elsif keyinput = intstr (8) then % Demon
        race := 8
        STR := 7
        CON := 5
        INT := 5
        DEX := 3
    end if
    colour (white)
    colour (white)
elsif cmd = "Load" then
    cls
    LoadFile
elsif cmd = "Exit" then
    put ""
    put "Goodbye!"
    delay (500)
    Window.Close (w)
    quit
end if

procedure CheckTime
    if timeOfDay >= 24 then
        timeOfDay := timeOfDay - 24
        day := day + 1
    end if
end CheckTime

% Plays hit sound when you inflict damage on your enemy.
process HitSound
    randint (soundRoll, 1, 3)
    if soundRoll = 1 then
        Music.PlayFile ("AssetFiles/sounds/battle/swing.wav")
    elsif soundRoll = 2 then
        Music.PlayFile ("AssetFiles/sounds/battle/swing2.wav")
    elsif soundRoll = 3 then
        Music.PlayFile ("AssetFiles/sounds/battle/swing3.wav")
    end if
end HitSound

% Plays sound when you cast spells.
process SpellSound
    Music.PlayFile ("AssetFiles/sounds/battle/spell.wav")
end SpellSound

% Plays sound when you enter combat.
process BattleEntrySound
    randint (soundRoll, 1, 5)
    if soundRoll = 1 then
        Music.PlayFile ("AssetFiles/sounds/battle/sword-unsheathe.wav")
    elsif soundRoll = 2 then
        Music.PlayFile ("AssetFiles/sounds/battle/sword-unsheathe2.wav")
    elsif soundRoll = 3 then
        Music.PlayFile ("AssetFiles/sounds/battle/sword-unsheathe3.wav")
    elsif soundRoll = 4 then
        Music.PlayFile ("AssetFiles/sounds/battle/sword-unsheathe4.wav")
    elsif soundRoll = 5 then
        Music.PlayFile ("AssetFiles/sounds/battle/sword-unsheathe5.wav")
    end if
end BattleEntrySound

% Plays burp sound when you eat food! XD
process BurpSound
    Music.PlayFile ("AssetFiles/sounds/misc/burp.wav")
end BurpSound


procedure ClearBattle
    canHeal := false
    canFire := false
    canThunder := false
    canIce := false
end ClearBattle

% -- Prologue --
cls
if storyProgress = 0 then
    day := 1
    timeOfDay := 9
    put "Welcome to the RPG made by Sylvain Sauve!"
    put "In this RPG, you will do quests, battle monsters!"
    put "This is a text-based RPG that is also turn-based."
    put ""
    put "Press any key to continue."
    getch (keyinput)
    cls
    locate (maxrow div 2, (maxcol div 2) - 4)
    put "Prologue"
    locate ((maxrow div 2) + 1, (maxcol div 2) - 9)
    put "The Speech of King"
    delay (3000)
    cls
    locate (1, 1)
    colour (yellow)
    put "The King: I can sense something evil coming."
    delay (3000)
    colour (brightgreen)
    put name, " (You): What?"
    delay (1200)
    colour (yellow)
    put "The King: You see that dark castle in the distance?"
    delay (2000)
    colour (white)
    put "The King points you to the dark castle about 25km away."
    delay (2000)
    colour (brightgreen)
    put "You: Yes. What's so important?"
    delay (2000)
    colour (yellow)
    put "The King: The Dark Lord is planning to bring the eternal darkness. Only you can stop him!"
    delay (4000)
    colour (brightgreen)
    put "You: But I'm only level 1!"
    delay (2000)
    colour (yellow)
    put "The King: I shall call in my personal trainer to train you. I want you to level up."
    put "The King: When you get to level 30, fight the Dark Lord! I summon you, trainer."
    delay (4000)
    colour (grey)
    put "Combat Trainer: You called me?"
    delay (2000)
    colour (yellow)
    put "The King: I want you to train ", name, "."
    delay (2500)
    colour (grey)
    put "Combat Trainer: Yes, your majesty. Now, ", name, ", let's train!"
    delay (3000)
    colour (yellow)
    put "The King: I will give you few gold. The trainer will give you a weapon."
    delay (3000)
    colour (white)
    put "You got 10 gold and Kitchen Knife! It has been equipped!"
    weapon := "Kitchen_Knife"
    weaponDamage := 1
    weaponTier := 1
    gold := gold + 10
    delay (3000)
    colour (yellow)
    put "The King: Come back when you get to level 5 and I will give you a quest."
    delay (4000)
    cls
    delay (2000)
    colour (white)
    locate (maxrow div 2, (maxcol div 2) - 5)
    storyProgress := 1
    put "Chapter 1"
    locate ((maxrow div 2) + 1, (maxcol div 2) - 7)
    put "The Beginning"
    delay (3000)
    cls
    locate (1, 1)
    put "Type \"Battle\" to begin your first combat."
end if

% -- Quest #1: The Goblin's Fortress --
procedure Quest1Start
    cls
    colour (yellow)
    put "The King: You have gained strength."
    delay (2500)
    put "The King: I'm going to assign you the first quest."
    delay (3000)
    colour (brightgreen)
    put "You: Oh goodness! My first quest!"
    delay (2000)
    colour (yellow)
    put "The King: The Goblins are going to raid the town. Defeat the leader."
    delay (4000)
    colour (brightgreen)
    put "You: I can do that!"
    delay (2000)
    colour (yellow)
    put "The King: Good to hear that! Don't forget to buy better weapon and armour!"
    delay (4000)
    put "The King: Bring me the head of Goblin leader and I will reward you."
    delay (4000)
    colour (brightgreen)
    put "You: Challenge accepted."
    delay (3000)
    colour (white)
    put "You have left the castle."
    storyProgress := 2
    delay (3000)
end Quest1Start


% -- Quest #1 Conclusion --
procedure Quest1End
    cls
    colour (yellow)
    put "The King: Have you slain the Goblin Leader?."
    delay (2500)
    colour (brightgreen)
    put "You: Yes, I have. (You show the head)"
    delay (2000)
    colour (yellow)
    if choiceQM1 = 1 then % If you performed cannibalism.
        put "The King: I noticed some blood around your mouth. It looks like goblin blood."
        delay (4000)
        colour (brightgreen)
        put "You: Well... I just ate him as well. I did some cannibalism."
        delay (3000)
        colour (yellow)
        put "The King: I have no comments. Anyways..."
        delay (2500)
    end if
    put "The King: Your quest has been completed. I shall reward you with 80 Gold."
    gold := gold + 80
    delay (4000)
    colour (brightgreen)
    put "You: Thank you, your majesty."
    delay (2000)
    colour (yellow)
    put "The King: I will have another task for you at level 10."
    delay (4000)
    colour (white)
    put "You have left the castle."
    storyProgress := 4
    delay (3000)
end Quest1End

procedure Quest2Start
    cls
    colour (yellow)
    put "The King: Ah, yes! I do have a quest for you!"
    delay (3000)
    colour (brightgreen)
    put "You: What should I do?"

end Quest2Start

procedure UpdateStats
    % Calculate max HP
    if CON <= 5 then
        maxHP := (level * 5) + (CON * 5)
    elsif CON > 5 and CON <= 10 then
        maxHP := (level * 5) + ((CON - 5) * 10) + 25
    elsif CON > 10 and CON <= 15 then
        maxHP := (level * 5) + ((CON - 10) * 15) + 75
    elsif CON > 15 and CON <= 20 then
        maxHP := (level * 5) + ((CON - 15) * 20) + 150
    else
        maxHP := (level * 5) + 250
    end if
    % Bring overflowing HP down to max.
    if HP > maxHP then
        HP := maxHP
    end if
    % Bring overflowing MP down to max.
    if MP > maxMP then
        MP := maxMP
    end if
    MPwr := INT + 1
    PPwr := STR + 1
    maxHP := (level * 5) + (CON * 10)
    maxMP := 10 + (INT * 2)
    if maxHP > 999 then
        maxHP := 999
    end if
    if maxMP > 100 then
        maxMP := 100
    end if
end UpdateStats

procedure LevelUp
    cls
    level := level + 1
    hasPoints := true
    levelPic := Pic.FileNew ("AssetFiles/others/LevelUp.bmp")
    Pic.Draw (levelPic, 0, maxy - 100, picCopy)
    Pic.SetTransparentColour (levelPic, black)
    locate (6, 1)
    put "You have gained a level!"
    put "Your maximum HP has been increased by 5! You may pick an attribute to increase!"
    put "1: +1 Strength (+10% Sword Damage)"
    put "2: +1 Constitution (+10 Maximum HP)"
    put "3: +1 Intelligence (+10% Spell Power, +2 Maximum MP)"
    put "4: +1 Dexterity (+2% Dodge Chance, +1% Critical Chance)"
    put ""
    put "Current Stats"
    put "________________"
    put "Strength: ", STR
    put "Constitution: ", CON
    put "Intelligence: ", INT
    put "Dexterity: ", DEX
    maxHP := (level * 5) + (CON * 10)
    maxMP := 10 + (INT * 2)
    HP := maxHP
    MP := maxMP
    loop
        getch (keyinput)
        if keyinput = intstr (1) then
            if STR < 20 then
                STR := STR + 1
                hasPoints := false
            else
                put "This attribute is maxed out!"
            end if
        elsif keyinput = intstr (2) then
            if CON < 20 then
                CON := CON + 1
                hasPoints := false
            else
                put "This attribute is maxed out!"
            end if
        elsif keyinput = intstr (3) then
            if INT < 20 then
                INT := INT + 1
                hasPoints := false
            else
                put "This attribute is maxed out!"
            end if
        elsif keyinput = intstr (4) then
            if DEX < 20 then
                DEX := DEX + 1
                hasPoints := false
            else
                put "This attribute is maxed out!"
            end if
        end if
        exit when (hasPoints = false) or (STR >= 20 and CON >= 20 and INT >= 20 and DEX >= 20)
    end loop
    HP := maxHP
    MP := maxMP
    Pic.Free (levelPic)
    UpdateStats
end LevelUp

% -- STATS --
procedure Stats
    if level < levelCap then
        drawfillbox (0, maxy, 400, maxy - 20, black)
        drawfillbox (0, maxy, round (XP / ((level ** 2) * 10) * 400), maxy - 20, purple)
        drawbox (0, maxy, 400, maxy - 20, white)
        Font.Draw (name + ", Level " + intstr (level) + ", XP: " + intstr (XP) + " / " + intstr ((level ** 2) * 10), 10, maxy - 15, SysFont, white)
    else
        drawfillbox (0, maxy, 400, maxy - 20, black)
        drawfillbox (0, maxy, 400, maxy - 20, purple)
        drawbox (0, maxy, 400, maxy - 20, white)
        Font.Draw (name + ", Level: " + intstr (level) + ", XP: " + intstr (XP) + " / Max Level", 10, maxy - 15, SysFont, white)
    end if
    drawfillbox (000, maxy - 20, 200, maxy - 40, black)
    drawfillbox (200, maxy - 20, 400, maxy - 40, black)
    drawbox (000, maxy - 20, 200, maxy - 40, white)
    drawbox (200, maxy - 20, 400, maxy - 40, white)
    Font.Draw ("Total XP: " + intstr (totalXP), 10, maxy - 35, SysFont, white)
    Font.Draw ("Gold: " + intstr (gold), 210, maxy - 35, SysFont, white)

    drawfillbox (0, maxy - 40, 200, maxy - 60, black)
    drawfillbox (0, maxy - 40, round (HP / maxHP * 200), maxy - 60, brightred)
    drawbox (0, maxy - 40, 200, maxy - 60, white)
    Font.Draw ("HP: " + intstr (HP) + " / " + intstr (maxHP), 10, maxy - 55, ComicFont, white)

    drawfillbox (200, maxy - 40, 400, maxy - 60, black)
    drawfillbox (200, maxy - 40, 200 + round (MP / maxMP * 200), maxy - 60, brightblue)
    drawbox (200, maxy - 40, 400, maxy - 60, white)
    Font.Draw ("MP: " + intstr (MP) + " / " + intstr (maxMP), 210, maxy - 55, ComicFont, white)

    drawfillbox (0, maxy - 60, 200, maxy - 80, black)
    drawfillbox (0, maxy - 60, round (Hunger / 100 * 200), maxy - 80, 42)
    drawbox (0, maxy - 60, 200, maxy - 80, white)
    Font.Draw ("Hunger: " + intstr (Hunger) + " / " + intstr (maxHunger), 10, maxy - 75, ComicFont, white)
    locate (7, 1)
end Stats

% -- ENEMY STATS --
procedure EnemyStat

    drawbox (0, maxy - 100, 400, maxy - 120, white)
    Font.Draw (enemyName + ", Level " + intstr (enemyLevel), 10, maxy - 115, SysFont, white)


    drawfillbox (0, maxy - 120, 200, maxy - 140, black)
    drawfillbox (0, maxy - 120, round (enemyHP / enemyMaxHP * 200), maxy - 140, brightred)
    drawbox (0, maxy - 120, 200, maxy - 140, white)
    Font.Draw ("HP: " + intstr (enemyHP) + " / " + intstr (enemyMaxHP), 10, maxy - 135, ComicFont, white)

    drawfillbox (200, maxy - 120, 400, maxy - 140, black)
    drawfillbox (200, maxy - 120, 200 + round (enemyMP / enemyMaxMP * 200), maxy - 140, brightblue)
    drawbox (200, maxy - 120, 400, maxy - 140, white)
    Font.Draw ("MP: " + intstr (enemyMP) + " / " + intstr (enemyMaxMP), 210, maxy - 135, ComicFont, white)
    colour (white)
    locate (12, 1)
end EnemyStat

procedure main
    cls
    if timeOfDay < 12 then
        put "Day ", day, ", ", timeOfDay, " AM"
    elsif timeOfDay = 12 then
        put "Day ", day, ", 12 PM"
    else
        put "Day ", day, ", ", timeOfDay - 12, " PM"
    end if
    GUI.Refresh
end main

procedure Inn
    put "Rest at Inn for ", level, " Gold? It'll restore your HP and MP!"
    getch (keyinput)
    if keyinput = "y" or keyinput = "Y" then
        gold := gold - level
        HP := maxHP
        MP := maxMP
        put "Good night!"
        delay (1500)
        cls
        put "ZZZZZ..."
        delay (3000)
        put "The next morning..."
        delay (3000)
        timeOfDay := 6
        day := day + 1
    elsif keyinput = "n" or keyinput = "N" then
        put "You have exited the Inn."
        delay (2000)
    else
        put "Invalid command. Exiting Inn."
        delay (2000)
    end if
    main
end Inn

procedure Shop
    loop
        cls
        put "Welcome to the shop!"
        put "Buy new items here!"
        put ""
        put "Your Gold: ", gold
        put ""
        put "Available items"
        put "__________________________"
        put "1 - Health Potions"
        put "2 - Mana Potions"
        if weaponTier = 1 and level >= 2 then
            put "3 - Wooden Sword: +3 Power (10 Gold)"
        elsif weaponTier = 2 and level >= 4 then
            put "3 - Stone Sword: +6 Power (25 Gold)"
        elsif weaponTier = 3 and level >= 6 then
            put "3 - Iron Sword: +10 Power (40 Gold)"
        elsif weaponTier = 4 and level >= 8 then
            put "3 - Steel Sword: +15 Power (60 Gold)"
        elsif weaponTier = 5 and level >= 10 then
            put "3 - Mithril Sword: +21 Power (125 Gold)"
        elsif weaponTier = 6 and level >= 12 then
            put "3 - Titanium Sword: +28 Power (200 Gold)"
        elsif weaponTier = 7 and level >= 14 then
            put "3 - Draconian Sword: +36 Power (350 Gold)"
        elsif weaponTier = 8 and level >= 17 then
            put "3 - Diamond Sword: +45 Power (500 Gold)"
        elsif weaponTier = 9 and level >= 20 then
            put "3 - Obsidian Sword: +55 Power (750 Gold)"
        elsif weaponTier = 10 and level >= 25 then
            put "3 - Demonic Sword: +66 Power (1,000 Gold)"
        else
            put "No more weapon upgrades for now."
        end if
        if armourTier = 0 then
            put "4 - Cardboard Armour: +1 Defense (5 Gold)"
        elsif armourTier = 1 and level >= 2 then
            put "4 - Leather Armour: +2 Defense (15 Gold)"
        elsif armourTier = 2 and level >= 4 then
            put "4 - Chain Armour: +3 Defense (25 Gold)"
        elsif armourTier = 3 and level >= 6 then
            put "4 - Iron Armour: +4 Defense (40 Gold)"
        elsif armourTier = 4 and level >= 8 then
            put "4 - Steel Armour: +5 Defense (75 Gold)"
        elsif armourTier = 5 and level >= 10 then
            put "4 - Mithril Armour: +6 Defense (125 Gold)"
        elsif armourTier = 6 and level >= 12 then
            put "4 - Titanium Armour: +8 Defense (220 Gold)"
        elsif armourTier = 7 and level >= 14 then
            put "4 - Draconian Armour: +10 Defense (350 Gold)"
        elsif armourTier = 8 and level >= 17 then
            put "4 - Diamond Armour: +12 Defense (500 Gold)"
        elsif armourTier = 9 and level >= 20 then
            put "4 - Obsidian Armour: +15 Defense (750 Gold)"
        elsif armourTier = 10 and level >= 25 then
            put "4 - Demonic Armour: +20 Defense (1,000 Gold)"
        else
            put "No more armour upgrades for now."
        end if
        % Heal
        if Heal = 0 then
            put "5 - Heal I (50 Gold)"
        elsif Heal = 1 and level >= 5 then
            put "5 - Heal II (200 Gold)"
        elsif Heal = 2 and level >= 15 then
            put "5 - Heal III (600 Gold)"
        elsif Heal = 3 then
            colour (grey)
            put "Maxed out!"
            colour (white)
        else
            put "Unavailable"
        end if
        % Fire
        if Fire = 0 and level >= 5 then
            put "6 - Burn (100 Gold)"
        elsif Fire = 1 and level >= 10 then
            put "6 - Fireball (250 Gold)"
        elsif Fire = 2 and level >= 15 then
            put "6 - Inferno (750 Gold)"
        elsif Fire = 3 then
            colour (grey)
            put "Maxed out!"
            colour (white)
        else
            colour (grey)
            put "Unavailable"
            colour (white)
        end if
        if Thunder = 0 and level >= 5 then
            put "7 - Electrocute (100 Gold)"
        elsif Thunder = 1 and level >= 10 then
            put "7 - Thunderbolt (300 Gold)"
        elsif Thunder = 2 and level >= 15 then
            put "7 - Thunderstorm (600 Gold)"
        elsif Thunder = 3 then
            colour (grey)
            put "Maxed out!"
            colour (white)
        else
            put "Unavailable"
        end if
        if Ice = 0 and level >= 4 then
            put "8 - Cold (100 Gold)"
        elsif Ice = 1 and level >= 8 then
            put "8 - Freeze (300 Gold)"
        elsif Ice = 2 and level >= 16 then
            put "8 - Blizzard (750 Gold)"
        elsif Ice = 3 then
            colour (grey)
            put "Maxed out!"
            colour (white)
        else
            put "Unavailable"
        end if
        put "9 - Market (Buy food)"
        put "0 - Exit shop"
        getch (keyinput)
        % -- Health Potions --
        if keyinput = "1" then
            put "What potions would you like?"
            put ""
            put "1 - Lesser Health Potion: 5 Gold (+20 HP) (", HPotion, "/5)"
            put "2 - Health Potion: 20 Gold (+50 HP) (", HPotionII, "/5)"
            put "3 - Greater Health Potion: 50 Gold (+100 HP) (", HPotionIII, "/5)"
            put ""
            put "0 - CANCEL"
            getch (keyinput)
            if keyinput = "1" then
                put "Buy Lesser Health Potion for 5 Gold? (Y/N)"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 5 then
                        if HPotion < 5 then
                            HPotion := HPotion + 1
                            gold := gold - 5
                            put "You have bought Lesser Health Potion!"
                        else
                            put "You can't carry more than 5 of this potion type!"
                        end if
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif keyinput = "N" or keyinput = "n" then
                    put "You have chosen not to buy potion."
                end if
            elsif keyinput = "2" then
                put "Buy Health Potion for 20 Gold? (Y/N)"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 20 then
                        if HPotionII < 5 then
                            HPotionII := MPotionII + 1
                            gold := gold - 20
                            put "You have bought Health Potion!"
                        else
                            put "You can't carry more than 5 of this potion type!"
                        end if
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif keyinput = "N" or keyinput = "n" then
                    put "You have chosen not to buy potion."
                end if
            elsif keyinput = "3" then
                put "Buy Greater Health Potion for 50 Gold? (Y/N)"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 50 then
                        if HPotionIII < 5 then
                            HPotionIII := HPotionIII + 1
                            gold := gold - 50
                            put "You have bought Greater Health Potion!"
                        else
                            put "You can't carry more than 5 of this potion type!"
                        end if
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif keyinput = "N" or keyinput = "n" then
                    put "You have chosen not to buy potion."
                end if
            end if
            delay (2000)
            % -- Mana Potions --
        elsif keyinput = "2" then
            put "What potions would you like?"
            put ""
            put "1 - Lesser Mana Potion: 5 Gold (+5 MP)"
            put "2 - Mana Potion: 20 Gold (+10 MP)"
            put "3 - Greater Mana Potion: 50 Gold (+20 MP)"
            put ""
            put "0 - CANCEL"
            getch (keyinput)
            if keyinput = "1" then
                put "Buy Lesser Mana Potion for 5 Gold? (Y/N)"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 5 then
                        if MPotion < 5 then
                            MPotion := MPotion + 1
                            gold := gold - 5
                            put "You have bought Lesser Mana Potion!"
                        else
                            put "You can't carry more than 5 of this potion type!"
                        end if
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif keyinput = "N" or keyinput = "n" then
                    put "You have chosen not to buy potion."
                end if
            elsif keyinput = "2" then
                put "Buy Mana Potion for 20 Gold? (Y/N)"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 20 then
                        if MPotionII < 5 then
                            MPotionII := MPotionII + 1
                            gold := gold - 20
                            put "You have bought Mana Potion!"
                        else
                            put "You can't carry more than 5 of this potion type!"
                        end if
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif keyinput = "N" or keyinput = "n" then
                    put "You have chosen not to buy potion."
                end if
            elsif keyinput = "3" then
                put "Buy Greater Mana Potion for 50 Gold? (Y/N)"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 50 then
                        if MPotionIII < 5 then
                            MPotionIII := MPotionIII + 1
                            gold := gold - 50
                            put "You have bought Greater Mana Potion!"
                        else
                            put "You can't carry more than 5 of this potion type!"
                        end if
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif keyinput = "N" or keyinput = "n" then
                    put "You have chosen not to buy potion."
                end if
            end if
            delay (2000)
            % -- Weapon --
        elsif keyinput = "3" then
            put "Upgrade to better weapon? (Y/N)"
            put "Your current weapon: ", weapon, ", +", weaponDamage, " Damage."
            if weaponTier = 1 then
                put "Your next weapon: Wooden Sword, +3 Damage"
                put "Cost: 10 Gold"
            elsif weaponTier = 2 then
                put "Your next weapon: Stone Sword, +6 Damage"
                put "Cost: 25 Gold"
            elsif weaponTier = 3 then
                put "Your next weapon: Iron Sword, +10 Damage"
                put "Cost: 40 Gold"
            elsif weaponTier = 4 then
                put "Your next weapon: Steel Sword, +15 Damage"
                put "Cost: 60 Gold"
            elsif weaponTier = 5 then
                put "Your next weapon: Mithril Sword, +21 Damage"
                put "Cost: 125 Gold"
            elsif weaponTier = 6 then
                put "Your next weapon: Titanium Sword, +28 Damage"
                put "Cost: 200 Gold"
            elsif weaponTier = 7 then
                put "Your next weapon: Draconian Sword, +36 Damage"
                put "Cost: 350 Gold"
            elsif weaponTier = 8 then
                put "Your next weapon: Diamond Sword, +45 Damage"
                put "Cost: 500 Gold"
            elsif weaponTier = 9 then
                put "Your next weapon: Obsidian Sword, +55 Damage"
                put "Cost: 750 Gold"
            elsif weaponTier = 10 then
                put "Your next weapon: Demonic Sword, +66 Damage"
                put "Cost: 1,000 Gold"
            else
                put "There is no more upgrades!"
            end if
            getch (keyinput)
            if keyinput = "Y" or keyinput = "y" then
                if weaponTier = 1 then
                    if gold >= 10 then
                        gold := gold - 10
                        weapon := "Wooden_Sword"
                        weaponDamage := 3
                        weaponTier := 2
                        put "You have bought Wooden Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 2 then
                    if gold >= 25 then
                        gold := gold - 25
                        weapon := "Stone_Sword"
                        weaponDamage := 6
                        weaponTier := 3
                        put "You have bought Stone Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 3 then
                    if gold >= 40 then
                        gold := gold - 40
                        weapon := "Iron_Sword"
                        weaponDamage := 10
                        weaponTier := 4
                        put "You have bought Iron Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 4 then
                    if gold >= 75 then
                        gold := gold - 75
                        weapon := "Steel_Sword"
                        weaponDamage := 15
                        weaponTier := 5
                        put "You have bought Steel Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 5 then
                    if gold >= 125 then
                        gold := gold - 125
                        weapon := "Mithril_Sword"
                        weaponDamage := 21
                        weaponTier := 6
                        put "You have bought Mithril Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 6 then
                    if gold >= 200 then
                        gold := gold - 200
                        weapon := "Titanium_Sword"
                        weaponDamage := 28
                        weaponTier := 7
                        put "You have bought Titanium Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 7 then
                    if gold >= 350 then
                        gold := gold - 350
                        weapon := "Draconian_Sword"
                        weaponDamage := 36
                        weaponTier := 8
                        put "You have bought Draconian Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 8 then
                    if gold >= 500 then
                        gold := gold - 500
                        weapon := "Diamond_Sword"
                        weaponDamage := 45
                        weaponTier := 9
                        put "You have bought Diamond Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 9 then
                    if gold >= 750 then
                        gold := gold - 750
                        weapon := "Obsidian_Sword"
                        weaponDamage := 55
                        weaponTier := 10
                        put "You have bought Obsidian Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif weaponTier = 10 then
                    if gold >= 1000 then
                        gold := gold - 1000
                        weapon := "Demonic_Sword"
                        weaponDamage := 66
                        weaponTier := 11
                        put "You have bought Demonic Sword! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                else
                    put "Really? You can't buy any more upgrades!"
                end if
            elsif keyinput = "N" or keyinput = "n" then
                put "You have chosen not to buy weapon upgrade."
                delay (2000)
            end if
            % -- Armour --
        elsif keyinput = "4" then
            put "Upgrade to better armour? (Y/N)"
            put "Your current armour: ", armour, ", +", armourProtection, " Protection."
            if armourTier = 0 then
                put "Your next armour: Cardboard Armour, +1 Protection"
                put "Cost: 5 Gold"
            elsif armourTier = 1 then
                put "Your next armour: Leather Armour, +2 Protection"
                put "Cost: 15 Gold"
            elsif armourTier = 2 then
                put "Your next armour: Chain Armour, +3 Protection"
                put "Cost: 25 Gold"
            elsif armourTier = 3 then
                put "Your next armour: Iron Armour, +4 Protection"
                put "Cost: 40 Gold"
            elsif armourTier = 4 then
                put "Your next armour: Steel Armour, +5 Protection"
                put "Cost: 75 Gold"
            elsif armourTier = 5 then
                put "Your next armour: Mithril Armour, +6 Protection"
                put "Cost: 125 Gold"
            elsif armourTier = 6 then
                put "Your next armour: Titanium Armour, +8 Protection"
                put "Cost: 220 Gold"
            elsif armourTier = 7 then
                put "Your next armour: Draconian Armour, +10 Protection"
                put "Cost: 350 Gold"
            elsif armourTier = 8 then
                put "Your next armour: Diamond Armour, +12 Protection"
                put "Cost: 500 Gold"
            elsif armourTier = 9 then
                put "Your next armour: Obsidian Armour, +15 Protection"
                put "Cost: 750 Gold"
            elsif armourTier = 10 then
                put "Your next armour: Demonic Armour, +20 Protection"
                put "Cost: 1000 Gold"
            else
                put "There is no more upgrades!"
            end if
            getch (keyinput)
            if keyinput = "Y" or keyinput = "y" then
                if armourTier = 0 then
                    if gold >= 5 then
                        gold := gold - 5
                        armour := "Cardboard_Armour"
                        armourProtection := 1
                        armourTier := 1
                        put "You have bought Cardboard Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 1 then
                    if gold >= 15 then
                        gold := gold - 15
                        armour := "Leather_Armour"
                        armourProtection := 2
                        armourTier := 2
                        put "You have bought Leather Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 2 then
                    if gold >= 25 then
                        gold := gold - 25
                        armour := "Chain_Armour"
                        armourProtection := 3
                        armourTier := 3
                        put "You have bought Chain Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 3 then
                    if gold >= 40 then
                        gold := gold - 40
                        armour := "Iron_Armour"
                        armourProtection := 4
                        armourTier := 4
                        put "You have bought Iron Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 4 then
                    if gold >= 75 then
                        gold := gold - 75
                        armour := "Steel_Armour"
                        armourProtection := 5
                        armourTier := 5
                        put "You have bought Steel Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 5 then
                    if gold >= 125 then
                        gold := gold - 125
                        armour := "Mithril_Armour"
                        armourProtection := 6
                        armourTier := 6
                        put "You have bought Mithril Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 6 then
                    if gold >= 220 then
                        gold := gold - 220
                        armour := "Titanium_Armour"
                        armourProtection := 8
                        armourTier := 7
                        put "You have bought Titanium Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 7 then
                    if gold >= 350 then
                        gold := gold - 350
                        armour := "Draconian_Armour"
                        armourProtection := 10
                        armourTier := 8
                        put "You have bought Draconian Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 8 then
                    if gold >= 500 then
                        gold := gold - 500
                        armour := "Diamond_Armour"
                        armourProtection := 12
                        armourTier := 9
                        put "You have bought Diamond Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 9 then
                    if gold >= 750 then
                        gold := gold - 750
                        armour := "Obsidian_Armour"
                        armourProtection := 15
                        armourTier := 10
                        put "You have bought Obsidian Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                elsif armourTier = 10 then
                    if gold >= 1000 then
                        gold := gold - 100
                        armour := "Demonic_Armour"
                        armourProtection := 20
                        armourTier := 11
                        put "You have bought Demonic Armour! It's equipped now!"
                        delay (3000)
                    else
                        put "Insufficient Gold!"
                        delay (3000)
                    end if
                else
                    put "Really? You can't buy any more upgrades!"
                end if
            elsif keyinput = "N" or keyinput = "n" then
                put "You have chosen not to buy weapon upgrade."
                delay (2000)
            end if
            % -- Heal Spell --
        elsif keyinput = "5" then
            if Heal = 0 then
                put "Buy Heal Spell I for 50 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 50 then
                        gold := gold - 50
                        put "You have bought Heal!"
                        Heal := 1
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Heal = 1 and level >= 5 then
                put "Buy Heal Spell II for 200 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 200 then
                        gold := gold - 200
                        put "You have bought Heal II!"
                        Heal := 2
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Heal = 2 and level >= 15 then
                put "Buy Heal Spell III for 600 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 600 then
                        gold := gold - 600
                        put "You have bought Heal III!"
                        Heal := 3
                    end if
                else
                    put "You have cancelled."
                end if
            else
                put "You have maxed out Heal spell!"
            end if
            % -- Fire Spell --
        elsif keyinput = "6" then
            if Fire = 0 and level >= 5 then
                put "Buy Burn Spell for 100 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 100 then
                        gold := gold - 100
                        put "You have bought Burn!"
                        Fire := 1
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Fire = 1 and level >= 10 then
                put "Buy Fireball Spell for 250 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 250 then
                        gold := gold - 250
                        put "You have bought Fireball!"
                        Fire := 2
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Fire = 2 and level >= 15 then
                put "Buy Inferno for 750 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 750 then
                        gold := gold - 750
                        put "You have bought Inferno!"
                        Fire := 3
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            else
                put "You have maxed out Fire spell!"
            end if
            % -- Thunder Spell --
        elsif keyinput = "7" then
            if Thunder = 0 and level >= 5 then
                put "Buy Shock Spell for 100 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 100 then
                        gold := gold - 100
                        put "You have bought Shock!"
                        Thunder := 1
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Thunder = 1 and level >= 10 then
                put "Buy Thunderbolt Spell for 250 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 250 then
                        gold := gold - 250
                        put "You have bought Thunderbolt!"
                        Thunder := 2
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Thunder = 2 and level >= 20 then
                put "Buy Thunderstorm for 600 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 750 then
                        gold := gold - 750
                        put "You have bought Thunderstorm!"
                        Thunder := 3
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            else
                put "You have maxed out Thunder spell!"
            end if
        elsif keyinput = "8" then
            if Ice = 0 and level >= 4 then
                put "Buy Cold Spell for 100 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 100 then
                        gold := gold - 100
                        put "You have bought Cold!"
                        Ice := 1
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Ice = 1 and level >= 8 then
                put "Buy Freeze Spell for 300 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 300 then
                        gold := gold - 300
                        put "You have bought Freeze!"
                        Ice := 2
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            elsif Ice = 2 and level >= 16 then
                put "Buy Blizzard for 750 Gold?"
                getch (keyinput)
                if keyinput = "Y" or keyinput = "y" then
                    if gold >= 750 then
                        gold := gold - 750
                        put "You have bought Blizzard!"
                        Ice := 3
                    else
                        put "Insufficient gold!"
                    end if
                else
                    put "You have cancelled."
                end if
            else
                put "You have maxed out Ice spell!"
            end if
            % -- Food --
        elsif keyinput = "9" then
            loop
                cls
                put "Welcome to the market! Here, you can buy food!"
                put "Eating food refills your hunger as well as some HP and MP."
                put ""
                put "Gold: ", gold
                put "__________"
                put "1 - Bread"
                put "2 - Cheese"
                put "3 - Meat"
                put ""
                put "0 - Exit"
                getch (keyinput)

                if keyinput = intstr (1) then
                    put "Would you like to buy a bread for ", (level + 5), " gold?"
                    getch (keyinput)
                    if keyinput = "Y" or keyinput = "y" then
                        if bread < 5 then
                            if gold >= (level + 5) then
                                gold := gold - (level + 5)
                                bread := bread + 1
                                put "You have bought a bread!"
                                put "To eat it, go to your 'Stats and Inventory', then select 'Food and Potions' and finally select Bread."
                            else
                                put "Insufficient gold!"
                            end if
                        else
                            put "You can't carry more bread! Please eat one before buying more."
                        end if
                    else
                        put "You have cancelled."
                    end if
                elsif keyinput = intstr (2) then
                    put "Would you like to buy cheese for ", round (level * 1.5 + 8), " gold?"
                    getch (keyinput)
                    if keyinput = "Y" or keyinput = "y" then
                        if cheese < 5 then
                            if gold >= round (level * 1.5 + 8) then
                                gold := gold - round (level * 1.5 + 8)
                                cheese := cheese + 1
                                put "You have bought a wedge of cheese!"
                                put "To eat it, go to your 'Stats and Inventory', then select 'Food and Potions' and finally select Cheese."
                            else
                                put "Insufficient gold!"
                            end if
                        else
                            put "You can't carry more cheese! Please eat one before buying more."
                        end if
                    else
                        put "You have cancelled."
                    end if
                elsif keyinput = intstr (3) then
                    put "Would you like to buy meat for ", round (level * 2 + 16), " gold?"
                    getch (keyinput)
                    if keyinput = "Y" or keyinput = "y" then
                        if meat < 5 then
                            if gold >= round (level * 2 + 16) then
                                gold := gold - round (level * 2 + 16)
                                meat := meat + 1
                                put "You have bought delicious cooked meat!"
                                put "To eat it, go to your 'Stats and Inventory', then select 'Food and Potions' and finally select Meat."
                            else
                                put "Insufficient gold!"
                            end if
                        else
                            put "You can't carry more cheese! Please eat one before buying more."
                        end if
                    else
                        put "You have cancelled."
                    end if
                end if
                delay (2000)
                exit when keyinput = intstr (0)
            end loop
        elsif keyinput = "0" then
            put "You have exited the shop."
            delay (2000)
        end if
        exit when keyinput = "0"
        put ""
        put "Press any key to continue shopping."
        getch (keyinput)
    end loop
    main
end Shop


% -- Combat Engine --
procedure Combat
    cls
    % Enemy Generator
    if isEnemyRandom = true then
        randint (RandEnemy, 1, 3)
        if level < 20 then
            randint (enemyLevel, level div 2, level)
        else
            randint (enemyLevel, (level div 3) * 2, level)
        end if
        if enemyLevel = 0 then
            enemyLevel := 1
        end if
        if enemyLevel = 1 or enemyLevel = 2 then
            enemyName := "Rat"
        elsif enemyLevel = 3 or enemyLevel = 4 then
            if RandEnemy = 1 then
                enemyName := "Goblin"
            elsif RandEnemy = 2 then
                enemyName := "Petty Thief"
            elsif RandEnemy = 3 then
                enemyName := "Young Wolf"
            end if
        elsif enemyLevel = 5 or enemyLevel = 6 then
            if RandEnemy = 1 then
                enemyName := "Wolf"
            elsif RandEnemy = 2 then
                enemyName := "Goblin Soldier"
            elsif RandEnemy = 3 then
                enemyName := "Goblin Mage"
            end if
        elsif enemyLevel = 7 or enemyLevel = 8 then
            if RandEnemy = 1 then
                enemyName := "Hobgoblin"
            elsif RandEnemy = 2 then
                enemyName := "Bandit"
            elsif RandEnemy = 3 then
                enemyName := "Thief"
            end if
        elsif enemyLevel = 9 then
            if RandEnemy = 1 then
                enemyName := "Troll"
            elsif RandEnemy = 2 then
                enemyName := "Bear"
            elsif RandEnemy = 3 then
                enemyName := "Wolf Pack Leader"
            end if
        elsif enemyLevel = 10 then
            enemyName := "Skeleton Swordsman"
        elsif enemyLevel = 11 then
            enemyName := "Skeleton Mage"
            canHeal := true
            canFire := false
            canThunder := false
            canIce := true
            enemySpellPower := 3
            enemyHealCost := 20
            enemyIceCost := 25
            enemyMaxOffset := 7
        elsif enemyLevel = 12 then
            enemyName := "Skeleton Brute"
        elsif enemyLevel = 13 then
            enemyName := "Wraith"
        elsif enemyLevel = 14 then
            if RandEnemy = 1 or RandEnemy = 2 then
                enemyName := "Lich"
            elsif RandEnemy = 3 then
                enemyName := "Creeper"
            end if
        elsif enemyLevel = 15 or enemyLevel = 16 then
            if RandEnemy = 1 or RandEnemy = 2 then
                enemyName := "Ancient Spirit"
            elsif RandEnemy = 3 then
                enemyName := "Creeper"
            end if
        elsif enemyLevel = 17 or enemyLevel = 18 then
            enemyName := "Hellhound"
        elsif enemyLevel = 19 or enemyLevel = 20 then
            enemyName := "Demon Mage"
            canHeal := true
            canFire := true
            canThunder := false
            canIce := false
            enemySpellPower := 4
            enemyHealCost := 15
            enemyFireCost := 25
            enemyMaxOffset := 10
        elsif enemyLevel = 21 or enemyLevel = 22 then
            enemyName := "Demon Warrior"
        elsif enemyLevel = 23 or enemyLevel = 24 then
            enemyName := "Demon Brute"
        elsif enemyLevel >= 25 then
            enemyName := "Infernal Demon"
            canHeal := false
            canFire := true
            canThunder := false
            canIce := false
            enemySpellPower := 5
            enemyHealCost := 0
            enemyFireCost := 25
            enemyMaxOffset := 10
        end if
        randint (EnemyMaxHPRoll, 0, enemyLevel * 2)
        if enemyLevel < 8 then
            enemyMaxHP := enemyLevel ** 2 + EnemyMaxHPRoll + 20
        elsif enemyLevel >= 8 and enemyLevel < 12 then
            enemyMaxHP := enemyLevel ** 2 + EnemyMaxHPRoll + 10
        else
            enemyMaxHP := enemyLevel ** 2 + EnemyMaxHPRoll
        end if
        if enemyMaxHP > 9999 then
            enemyMaxHP := 9999
        end if
    end if


    if isBoss = false then
        enemyDamage := enemyLevel * 2
        enemyXP := (enemyLevel * 5) + (enemyMaxHP div 5)
        enemyGold := enemyLevel + (enemyMaxHP div 10)
        enemyMaxMP := 100
    end if
    enemyHP := enemyMaxHP
    enemyMP := enemyMaxMP

    Stats
    EnemyStat
    fork BattleEntrySound
    % Commands
    loop
        put "Press the numbered keys to perform the corresponding actions."
        put ""
        put "1 - Attack"
        put "2 - Magic"
        put "3 - Potions"
        put "4 - Run"
        put ""
        colour (brightgreen)
        getch (keyinput)
        colour (white)
        randint (DamageTaken, enemyLevel, enemyDamage)
        DamageTaken := round (DamageTaken * (1 - (armourProtection / 50)))
        % Attack command
        if keyinput = intstr (1) then
            PPwr := weaponDamage + STR
            randint (DamageDealt, PPwr, PPwr + level)
            randint (CritRoll, 1, 100)
            randint (HitRoll, 1, 100)     % Try to hit.
            didAttack := true
            Stats
            EnemyStat
            if HitRoll > (20 - (DEX * 2) + ((enemyLevel - level) * 2)) then
                DamageDealt := DamageDealt
            else
                CritRoll := 0
                DamageDealt := 0     % You miss!
            end if
            cls
            if CritRoll >= 95 - (DEX) then
                DamageDealt := DamageDealt * 2
                locate (10, 1)
                put "CRITICAL HIT!"
            end if
            locate (11, 1)
            if DamageDealt > 0 then
                put "You hit ", enemyName, " for ", DamageDealt, " damage!"
                fork HitSound
            else
                put "You missed."
            end if
            enemyHP := enemyHP - DamageDealt
            % Magic command
        elsif keyinput = intstr (2) then
            if Heal = 0 then
                put "1 - Heal (LOCKED)"
            elsif Heal = 1 then
                put "1 - Lesser Heal (4 MP)"
            elsif Heal = 2 then
                put "1 - Heal (7 MP)"
            elsif Heal = 3 then
                put "1 - Greater Heal (10 MP)"
            end if
            if Fire = 0 then
                put "2 - Fire (LOCKED)"
            elsif Fire = 1 then
                put "2 - Burn (3 MP)"
            elsif Fire = 2 then
                put "2 - Fireball (6 MP)"
            elsif Fire = 3 then
                put "2 - Inferno (9 MP)"
            end if
            if Thunder = 0 then
                put "3 - Thunder (LOCKED)"
            elsif Thunder = 1 then
                put "3 - Shock (4 MP)"
            elsif Thunder = 2 then
                put "3 - Thunder (6 MP)"
            elsif Thunder = 3 then
                put "3 - Thunderstorm (8 MP)"
            end if
            if Ice = 0 then
                put "4 - Ice (LOCKED)"
            elsif Ice = 1 then
                put "4 - Cold (3 MP)"
            elsif Ice = 2 then
                put "4 - Freeze (5 MP)"
            elsif Ice = 3 then
                put "4 - Blizzard (8 MP)"
            end if
            put "0 - Cancel"
            getch (keyinput)
            didAttack := true
            % Heal
            if keyinput = "1" then
                if Heal = 0 then
                    put "This spell is locked."
                elsif Heal = 1 then
                    if MP >= 4 then
                        MP := MP - 4
                        HP := HP + (10 + MPwr)
                        put "You have restored ", (10 + MPwr), " HP!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Heal = 2 then
                    if MP >= 7 then
                        MP := MP - 7
                        HP := HP + (20 + MPwr * 2)
                        put "You have restored ", (20 + MPwr * 2), " HP!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Heal = 3 then
                    if MP >= 10 then
                        MP := MP - 10
                        HP := HP + (40 + MPwr * 4)
                        put "You have restored ", (40 + MPwr * 4), " HP!"
                    else
                        put "Insufficient Mana!"
                    end if
                end if
                if HP > maxHP then
                    HP := maxHP
                end if
                fork SpellSound
                % Fire
            elsif keyinput = "2" then
                if Fire = 0 then
                    put "This spell is locked."
                elsif Fire = 1 then
                    if MP >= 3 then
                        MP := MP - 3
                        randint (DamageDealt, 5, 10)
                        enemyHP := enemyHP - round (DamageDealt + (MPwr))
                        put "You have casted Burn and inflicted ", (DamageDealt + (MPwr)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Fire = 2 then
                    if MP >= 6 then
                        MP := MP - 6
                        randint (DamageDealt, 10, 20)
                        enemyHP := enemyHP - round (DamageDealt + (MPwr * 2))
                        put "You have casted Fireball and inflicted ", (DamageDealt + (MPwr * 2)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Fire = 3 then
                    if MP >= 9 then
                        MP := MP - 9
                        randint (DamageDealt, 20, 40)
                        enemyHP := enemyHP - round (DamageDealt + (MPwr * 4))
                        put "You have casted Inferno and inflicted ", (DamageDealt + (MPwr * 4)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                end if
            elsif keyinput = "3" then
                if Thunder = 0 then
                    put "This spell is locked."
                elsif Thunder = 1 then
                    if MP >= 4 then
                        MP := MP - 4
                        randint (DamageDealt, 3, 16)
                        enemyHP := enemyHP - (DamageDealt + (MPwr))
                        put "You have casted Shock and inflicted ", (DamageDealt + (MPwr)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Thunder = 2 then
                    if MP >= 6 then
                        MP := MP - 6
                        randint (DamageDealt, 6, 32)
                        enemyHP := enemyHP - (DamageDealt + (MPwr * 2))
                        put "You have casted Thunder and inflicted ", (DamageDealt + (MPwr * 2)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Thunder = 3 then
                    if MP >= 8 then
                        MP := MP - 8
                        randint (DamageDealt, 12, 64)
                        enemyHP := enemyHP - (DamageDealt + (MPwr * 4))
                        put "You have casted Thunderstorm and inflicted ", (DamageDealt + (MPwr * 4)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                end if
                % Ice
            elsif keyinput = "4" then
                if Ice = 0 then
                    put "This spell is locked."
                elsif Ice = 1 then
                    if MP >= 3 then
                        MP := MP - 3
                        randint (DamageDealt, 10, 10)
                        enemyHP := enemyHP - (DamageDealt + (MPwr))
                        put "You have casted Cold and inflicted ", (DamageDealt + (MPwr)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Ice = 2 then
                    if MP >= 5 then
                        MP := MP - 5
                        randint (DamageDealt, 30, 30)
                        enemyHP := enemyHP - (DamageDealt + (MPwr * 2))
                        put "You have casted Freeze and inflicted ", (DamageDealt + (MPwr * 2)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                elsif Ice = 3 then
                    if MP >= 8 then
                        MP := MP - 8
                        randint (DamageDealt, 60, 60)
                        enemyHP := enemyHP - (DamageDealt + (MPwr * 4))
                        put "You have casted Blizzard and inflicted ", (DamageDealt + (MPwr * 4)), " damage on ", enemyName, "!"
                    else
                        put "Insufficient Mana!"
                    end if
                end if
            elsif keyinput = "0" then
                put "You have cancelled."
                didAttack := false
                delay (1000)
            end if
        elsif keyinput = intstr (3) then
            put "Choose a potion to use."
            put ""
            put "1 - Lesser HP Potion (+20 HP)(x", HPotion, ")"
            put "2 - Lesser MP Potion (+5 MP)(x", MPotion, ")"
            put "3 - Medium HP Potion (+50 HP)(x", HPotionII, ")"
            put "4 - Medium MP Potion (+10 MP)(x", MPotionII, ")"
            put "5 - Greater HP Potion (+100 HP)(x", HPotionIII, ")"
            put "6 - Greater MP Potion (+20 MP)(x", MPotionIII, ")"
            put ""
            put "0 - Cancel"
            getch (keyinput)
            didAttack := true
            if keyinput = "1" then
                if HPotion > 0 then
                    HPotion := HPotion - 1
                    if (HP + 20) <= maxHP then
                        HP := HP + 20
                    else
                        HP := maxHP
                    end if
                    put "You regained 20 HP!"
                else
                    put "You have no potions of this type!"
                end if
            elsif keyinput = "2" then
                if MPotion > 0 then
                    MPotion := MPotion - 1
                    put "You regained 5 MP!"
                    if (MP + 5) <= maxMP then
                        MP := MP + 20
                    else
                        MP := maxMP
                    end if
                    put "You regained 5 MP!"
                else
                    put "You have no potions of this type!"
                end if
            elsif keyinput = "3" then
                if HPotionII > 0 then
                    HPotionII := HPotionII - 1
                    if (HP + 50) <= maxHP then
                        HP := HP + 50
                    else
                        HP := maxHP
                    end if
                    put "You regained 50 HP!"
                else
                    put "You have no potions of this type!"
                end if
            elsif keyinput = "4" then
                if MPotionII > 0 then
                    MPotionII := MPotionII - 1
                    if (MP + 10) <= maxMP then
                        MP := MP + 10
                    else
                        MP := maxMP
                    end if
                    put "You regained 10 MP!"
                else
                    put "You have no potions of this type!"
                end if
            elsif keyinput = "5" then
                if HPotionIII > 0 then
                    HPotionIII := HPotionIII - 1
                    if (HP + 100) <= maxHP then
                        HP := HP + 100
                    else
                        HP := maxHP
                    end if
                    put "You regained 100 HP!"
                else
                    put "You have no potions of this type!"
                end if
            elsif keyinput = "6" then
                if MPotionIII > 0 then
                    MPotionIII := MPotionIII - 1
                    if (MP + 20) <= maxMP then
                        MP := MP + 20
                    else
                        MP := maxMP
                    end if
                    put "You regained 20 MP!"
                else
                    put "You have no potions of this type!"
                end if
            elsif keyinput = "0" then
                put "You cancelled."
                didAttack := false
                delay (1000)
            end if
        end if
        % -- Enemy's Turn
        randint (HitRoll, 1, 100)
        if DEX <= 20 then
            if HitRoll < 10 + (DEX) + ((level - enemyLevel) * 2) then
                DamageTaken := 0     % Enemy misses.
            end if
        else
            if HitRoll < 30 + ((level - enemyLevel) * 2) then
                DamageTaken := 0     % Enemy misses.
            end if
        end if
        Stats
        EnemyStat

        if didAttack = true then
            randint (enemyChoice, 1, 100)
            if enemyHP > 0 then
                delay (3000)

                % -- Enemy AI --

                % Heal Spell
                if canHeal = true then
                    if enemyHP < round (enemyMaxHP * 0.8) then
                        if enemyChoice >= 80 then
                            if enemyMP >= 10 then
                                enemyMP := enemyMP - 10
                                enemyHP := enemyHP + (enemySpellPower * enemyLevel)
                                EnemyStat
                                put "Your enemy healed for ", (enemySpellPower * enemyLevel), "HP!"
                                enemyDidAttack := true
                            end if
                        end if
                    elsif enemyHP < round (enemyMaxHP * 0.2) then
                        if enemyMP > 10 then
                            enemyMP := enemyMP - 10
                            randint (enemySpellOffset, -enemyMaxOffset, enemyMaxOffset)
                            enemyHP := enemyHP + (enemySpellPower * enemyLevel)
                            EnemyStat
                            put "Your enemy healed for ", (enemySpellPower * enemyLevel), "HP!"
                            enemyDidAttack := true
                        end if
                    end if
                    if enemyHP > enemyMaxHP then
                        enemyHP := enemyMaxHP
                    end if
                end if

                % Fire Spell
                if canFire = true then
                    if enemyChoice >= 65 and enemyChoice < 80 then
                        if enemyMP >= enemyFireCost then
                            enemyMP := enemyMP - enemyFireCost
                            randint (enemySpellOffset, -enemyMaxOffset, enemyMaxOffset)
                            HP := HP - ceil (((enemySpellPower * enemyLevel) + enemySpellOffset) * 1 - (armourProtection / 50))
                            Stats
                            EnemyStat
                            put "Your enemy casted Fire spell and hits you for ", ceil (((enemySpellPower * enemyLevel) + enemySpellOffset) * 1 - (armourProtection / 50)), " damage! Burning!"
                            enemyDidAttack := true
                        end if
                    end if
                end if

                % Thunder Spell
                if canThunder = true then
                    if enemyChoice >= 50 and enemyChoice < 65 then
                        if enemyMP >= enemyThunderCost then
                            enemyMP := enemyMP - enemyThunderCost
                            randint (enemySpellOffset, -enemyMaxOffset, enemyMaxOffset)
                            HP := HP - ceil (((enemySpellPower * enemyLevel) + enemySpellOffset) * 1 - (armourProtection / 50))
                            Stats
                            EnemyStat
                            put "Your enemy casted Thunder spell and hits you for ", ceil (((enemySpellPower * enemyLevel) + enemySpellOffset) * 1 - (armourProtection / 50)), " damage! Shocking!"
                            enemyDidAttack := true
                        end if
                    end if
                end if

                % Ice Spell
                if canIce = true then
                    if enemyChoice >= 35 and enemyChoice < 50 then
                        if enemyMP >= enemyIceCost then
                            enemyMP := enemyMP - enemyIceCost
                            randint (enemySpellOffset, -enemyMaxOffset, enemyMaxOffset)
                            HP := HP - ceil (((enemySpellPower * enemyLevel) + enemySpellOffset) * 1 - (armourProtection / 50))
                            Stats
                            EnemyStat
                            put "Your enemy casted Ice spell and hits you for ", ceil (((enemySpellPower * enemyLevel) + enemySpellOffset) * 1 - (armourProtection / 50)), " damage! Chilling!"
                            enemyDidAttack := true
                        end if
                    end if
                end if


                % Regular Enemy Attack
                if enemyDidAttack = false then
                    if DamageTaken > 0 then
                        put enemyName, " hits you for ", DamageTaken, " damage!"
                        HP := HP - DamageTaken
                        Stats
                    else
                        put enemyName, " missed."
                    end if

                end if
            end if
            enemyDidAttack := false
            delay (3000)
        end if
        cls
        % Update hunger.
        if didAttack = true then
            if Hunger > 80 then
                HP := HP + (maxHP div 20)
                if HP > maxHP then
                    HP := maxHP
                end if
            end if
            if Hunger = 80 then
                put "You no longer feel full. Your HP no longer regenerates."
                delay (2000)
            end if
            if Hunger > 25 then
                MP := MP + 1
                if MP > maxMP then
                    MP := maxMP
                end if
            end if
            if Hunger = 25 then
                put "Your mana no longer regenerates due to hunger."
                delay (2000)
            end if
            if Hunger = 0 then
                HP := HP - (maxHP div 20)
                Stats
                EnemyStat
                put "You lose ", (maxHP div 20), " HP as you're starved."
                delay (2000)
            end if
            if Hunger > 0 then
                Hunger := Hunger - 1
            end if

            CountUntilTick := CountUntilTick + 1
            if CountUntilTick >= 5 then
                CountUntilTick := 0
                timeOfDay := timeOfDay + 1
                CheckTime
            end if
        end if
        Stats
        EnemyStat
        didAttack := false
        exit when HP <= 0 or enemyHP <= 0 or cmd = "Run"
    end loop
    if HP <= 0 then
        put "You are defeated! Game Over! You shall respawn."
        HP := 1
        delay (2000)
    end if
    if enemyHP <= 0 then
        cls
        Stats
        put "You are victorious! You gained ", enemyXP, " XP and ", enemyGold, " Gold!"
        gold := gold + enemyGold
        for x : 1 .. enemyXP
            if XP < maxint then
                XP := XP + 1
            end if
            if totalXP < maxint then
                totalXP := totalXP + 1
            end if
            Stats
            delay (2000 div enemyXP)
        end for
        delay (2000)
        if XP >= (level ** 2) * 10 then
            if level < levelCap then
                XP := XP - (level ** 2) * 10
                LevelUp
            end if
        end if
    end if
    ClearBattle
    cls
    if isEnemyRandom = true then
        main
    end if
    if HP <= 0 and isEnemyRandom = false then
        cls
        put "You have failed the quest! You may retry this quest."
        delay (3000)
        main
    end if
end Combat

main

procedure Quest1Midway
    isEnemyRandom := false
    cls
    put "You began your journey. " ..
    delay (2000)
    put "You walked..." ..
    delay (2000)
    put " and walked..." ..
    delay (2000)
    put " until you finally reached the Goblin Fortress."
    delay (3000)
    put ""
    colour (gray)
    put "Goblin: You shall not pass!"
    delay (3000)
    colour (brightgreen)
    put "You: Oh really? I'll fight if I have to!"
    colour (white)
    delay (4000)
    enemyName := "Goblin"
    enemyLevel := 5
    enemyMaxHP := 50
    Combat
    cls
    put "You opened the gates and went inside."
    colour (gray)
    put "Goblin Guard: Stop, intruder!"
    delay (2500)
    colour (white)
    put "You'll have to fight him!"
    delay (3000)
    enemyName := "Goblin Guard"
    enemyLevel := 6
    enemyMaxHP := 65
    Combat
    cls
    put "You went to the longhouse. You proceed to open the door and enter."
    delay (3000)
    colour (brightred)
    put "Goblin Chieftain: How dare you intrude! Guards, get this intruder!"
    delay (3000)
    colour (gray)
    put "Goblin Guards: Arrrrrgh!"
    delay (2500)
    colour (brightgreen)
    put "You: Time to end this!"
    delay (3000)
    colour (white)
    enemyName := "Goblin Guards"
    enemyLevel := 7
    enemyMaxHP := 150
    Combat
    cls
    colour (white)
    put "A pile of dead goblin guards fall before you."
    delay (3000)
    colour (brightred)
    put "Goblin Chieftain: That's only the warmup! " ..
    delay (2500)
    put "I am the deadliest of all the Goblins!"
    colour (white)
    delay (3000)
    put "The door closes and lock behind you."
    delay (3000)
    colour (brightgreen)
    put "You: We'll see about this!"
    delay (3000)
    cls
    for i : 1 .. 3
        drawfillbox (0, 0, maxx, maxy, brightred)
        delay (500)
        drawfillbox (0, 0, maxx, maxy, black)
        delay (500)
    end for
    Font.Draw ("Boss Fight!", maxx div 2 - 200, maxy div 2, LargeFont, brightred)
    delay (2000)
    enemyName := "Goblin Chieftain (Boss)"
    enemyLevel := 5
    enemyMaxHP := 300
    enemyMaxMP := 100
    enemyXP := 250
    enemyGold := 100
    canHeal := true
    canFire := true
    canThunder := false
    canIce := false
    enemySpellPower := 6
    enemyHealCost := 10
    enemyFireCost := 15
    enemyMaxOffset := 10
    isBoss := true
    Combat
    colour (red)
    put "Goblin Chieftain: Noooo!"
    delay (2500)
    colour (white)
    put "The Goblin Chieftain falls to the knees, then falls over."
    delay (3000)
    put "You take out your ", weapon, "."
    delay (3000)
    put "You manage to cut off the head of Goblin Chieftain."
    delay (3000)
    put "Obtained item: Goblin Chieftain Head!"
    delay (4000)
    cls
    put "Would you like to devour the chieftain? (Y/N)"
    getch (keyinput)
    loop
        if keyinput = "Y" or keyinput = "y" then
            put "You cut off the arm, cooked it and ate it."
            put "Your Hunger has been refilled. (+10 Corruption)"
            corruption := corruption + 10
            Hunger := maxHunger
            choiceQM1 := 1
        elsif keyinput = "N" or keyinput = "n" then
            put "You choose not to do it. (-10 Corruption)"
            corruption := corruption - 10
            choiceQM1 := 2
        end if
        exit when keyinput = "Y" or keyinput = "y" or keyinput = "N" or keyinput = "n"
    end loop
    delay (3000)
    put "The door unlocks. You open the door and exit the fortress."
    delay (3000)
    put "Time to return to the castle."
    delay (3000)
    put "You make your journey back to town."
    delay (3000)
    storyProgress := 3
    isEnemyRandom := true
end Quest1Midway

procedure FullStats
    cls
    Stats
    put "Your Attributes"
    put ""
    put "Strength: " : 15, STR, "" : 5, "Constitution: " : 15, CON
    put "Intelligence: " : 15, INT, "" : 5, "Dexterity: " : 15, DEX
    put ""
    put "Corruption: " : 15, corruption
    put "__________________________"
    put "Your Equipment"
    put ""
    put "Weapon: ", weapon, " (+", weaponDamage, " Damage)"
    put "Armour: ", armour, " (+", armourProtection, " Protection)"
    put "Accessory: ", accessory
    put "__________________________"
    BG := Pic.FileNew ("AssetFiles/others/Background.jpg")
    Pic.Draw (BG, maxx - 120, maxy - 220, 2)
    if gender = "Male" then
        if race = 1 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale1.bmp")
        elsif race = 2 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale2.bmp")
        elsif race = 3 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale3.bmp")
        elsif race = 4 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale4.bmp")
        elsif race = 5 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale5.bmp")
        elsif race = 6 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale6.bmp")
        elsif race = 7 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale7.bmp")
        elsif race = 8 then
            charPic := Pic.FileNew ("AssetFiles/character/CharMale8.bmp")
        end if
    else
        if race = 1 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale1.bmp")
        elsif race = 2 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale2.bmp")
        elsif race = 3 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale3.bmp")
        elsif race = 4 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale4.bmp")
        elsif race = 5 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale5.bmp")
        elsif race = 6 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale6.bmp")
        elsif race = 7 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale7.bmp")
        elsif race = 8 then
            charPic := Pic.FileNew ("AssetFiles/character/CharFemale8.bmp")
        end if
    end if
    Pic.SetTransparentColour (charPic, brightblue)
    Pic.Draw (charPic, maxx - 110, maxy - 210, 2)
    if armour = "Clothes" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Clothes.bmp")
    elsif armour = "Cardboard_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Cardboard_Armour.bmp")
    elsif armour = "Leather_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Leather_Armour.bmp")
    elsif armour = "Chain_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Chain_Armour.bmp")
    elsif armour = "Iron_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Iron_Armour.bmp")
    elsif armour = "Steel_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Steel_Armour.bmp")
    elsif armour = "Mithril_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Mithril_Armour.bmp")
    elsif armour = "Titanium_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Titanium_Armour.bmp")
    elsif armour = "Draconian_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Draconian_Armour.bmp")
    elsif armour = "Diamond_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Diamond_Armour.bmp")
    elsif armour = "Obsidian_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Obsidian_Armour.bmp")
    elsif armour = "Demonic_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Demonic_Armour.bmp")
    elsif armour = "Darklord_Armour" then
        armourPic := Pic.FileNew ("AssetFiles/armour/Darklord_Armour.bmp")
    end if
    Pic.SetTransparentColour (armourPic, brightblue)
    Pic.Draw (armourPic, maxx - 110, maxy - 210, 2)
    if weapon = "Kitchen_Knife" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/KitchenKnife.bmp")
    elsif weapon = "Wooden_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/WoodenSword.bmp")
    elsif weapon = "Stone_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/StoneSword.bmp")
    elsif weapon = "Iron_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/IronSword.bmp")
    elsif weapon = "Steel_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/SteelSword.bmp")
    elsif weapon = "Mithril_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/MithrilSword.bmp")
    elsif weapon = "Titanium_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/TitaniumSword.bmp")
    elsif weapon = "Draconian_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/DraconianSword.bmp")
    elsif weapon = "Diamond_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/DiamondSword.bmp")
    elsif weapon = "Obsidian_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/ObsidianSword.bmp")
    elsif weapon = "Demonic_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/DemonicSword.bmp")
    elsif weapon = "Darklord_Sword" then
        weaponPic := Pic.FileNew ("AssetFiles/weapon/DarklordSword.bmp")
    end if
    Pic.SetTransparentColour (weaponPic, brightblue)
    Pic.Draw (weaponPic, maxx - 110, maxy - 210, 2)
    put "1 - Equipment (Not yet implemented)"
    put "2 - Food and Potions"
    put "3 - Resources"
    put "4 - Heal Spell"
    put ""
    put "0 - Return"
    loop
        getch (keyinput)
        if strintok (keyinput) then
            case strint (keyinput) of
                label 1 :
                    cls
                    Stats
                    put "1 - Weapons"
                    put "2 - Armours"
                    put "3 - Accessories"
                    put ""
                    put "0 - Return"
                label 2 :
                    loop
                        cls
                        Stats
                        put "1 - Lesser Health Potion" : 25, "(", HPotion, "/5)", "(+20 HP)"
                        put "2 - Health Potion" : 25, "(", HPotionII, "/5)", "(+50 HP)"
                        put "3 - Greater Health Potion" : 25, "(", HPotionIII, "/5)", "(+100HP)"
                        put ""
                        put "4 - Lesser Mana Potion" : 25, "(", MPotion, "/5)", "( +5 MP)"
                        put "5 - Mana Potion" : 25, "(", MPotionII, "/5)", "(+10 MP)"
                        put "6 - Greater Mana Potion" : 25, "(", MPotionIII, "/5)", "(+20 MP)"
                        put ""
                        put "7 - Bread (", bread, "/5)(Refill 20% Hunger)"
                        put "8 - Cheese (", cheese, "/5)(Refill 40% Hunger)"
                        put "9 - Meat (", meat, "/5)(Refill 60% Hunger)"
                        put ""
                        put "0 - Exit"
                        getch (keyinput)
                        if strintok (keyinput) then
                            case strint (keyinput) of
                                label 1 :
                                    put "Would you like to use Lesser Health potion? It will restore 20 HP. (Y/N)"
                                    getch (keyinput)
                                    if keyinput = "y" or keyinput = "Y" then
                                        if HPotion > 0 then
                                            HPotion := HPotion - 1
                                            HP := HP + 20
                                            put "You drink the potion and restored 20 HP!"
                                        else
                                            put "You don't have any potions of this type!"
                                        end if
                                        if HP > maxHP then
                                            HP := maxHP
                                        end if
                                    else
                                        put "You cancelled."
                                    end if
                                    delay (2000)
                                label 2 :
                                    put "Would you like to use Health potion? It will restore 50 HP. (Y/N)"
                                    getch (keyinput)
                                    if keyinput = "y" or keyinput = "Y" then
                                        if HPotionII > 0 then
                                            HPotionII := HPotionII - 1
                                            HP := HP + 50
                                            put "You drink the potion and restored 50 HP!"
                                        else
                                            put "You don't have any potions of this type!"
                                        end if
                                        if HP > maxHP then
                                            HP := maxHP
                                        end if
                                    else
                                        put "You cancelled."
                                    end if
                                    delay (2000)
                                label 3 :
                                    put "Would you like to use Greater Health potion? It will restore 100 HP. (Y/N)"
                                    getch (keyinput)
                                    if keyinput = "y" or keyinput = "Y" then
                                        if HPotionIII > 0 then
                                            HPotionIII := HPotionIII - 1
                                            HP := HP + 100
                                            put "You drink the potion and restored 100 HP!"
                                        else
                                            put "You don't have any potions of this type!"
                                        end if
                                        if HP > maxHP then
                                            HP := maxHP
                                        end if
                                    else
                                        put "You cancelled."
                                    end if
                                    delay (2000)
                                label 4 :
                                    put "Would you like to use Lesser Mana potion? It will restore 5 MP. (Y/N)"
                                    getch (keyinput)
                                    if keyinput = "y" or keyinput = "Y" then
                                        if MPotion > 0 then
                                            MPotion := MPotion - 1
                                            MP := MP + 5
                                            put "You drink the potion and restored 5 MP!"
                                        else
                                            put "You don't have any potions of this type!"
                                        end if
                                        if MP > maxMP then
                                            MP := maxMP
                                        end if
                                    else
                                        put "You cancelled."
                                    end if
                                    delay (2000)
                                label 5 :
                                    put "Would you like to use Mana potion? It will restore 10 MP. (Y/N)"
                                    getch (keyinput)
                                    if keyinput = "y" or keyinput = "Y" then
                                        if MPotionII > 0 then
                                            MPotionII := MPotionII - 1
                                            MP := MP + 10
                                            put "You drink the potion and restored 10 MP!"
                                        else
                                            put "You don't have any potions of this type!"
                                        end if
                                        if MP > maxMP then
                                            MP := maxMP
                                        end if
                                    else
                                        put "You cancelled."
                                    end if
                                    delay (2000)
                                label 6 :
                                    put "Would you like to use Greater Mana potion? It will restore 20 MP. (Y/N)"
                                    getch (keyinput)
                                    if keyinput = "y" or keyinput = "Y" then
                                        if MPotionIII > 0 then
                                            MPotionIII := MPotionIII - 1
                                            MP := MP + 20
                                            put "You drink the potion and restored 20 MP!"
                                        else
                                            put "You don't have any potions of this type!"
                                        end if
                                        if MP > maxMP then
                                            MP := maxMP
                                        end if
                                    else
                                        put "You cancelled."
                                    end if
                                    delay (2000)
                                label 7 :
                                    if Hunger < 90 then
                                        put "Would you like to eat bread? It will refill 20% Hunger and restore 20% HP and MP."
                                        getch (keyinput)
                                        if keyinput = "y" or keyinput = "Y" then
                                            if bread > 0 then
                                                bread := bread - 1
                                                Hunger := Hunger + 20
                                                HP := HP + (maxHP div 5)
                                                MP := MP + (maxMP div 5)
                                                put "You ate the bread! Your hunger has been refilled!"
                                                fork BurpSound
                                            else
                                                put "You don't have any bread!"
                                            end if
                                            if Hunger > 100 then
                                                Hunger := 100
                                            end if
                                            if HP > maxHP then
                                                HP := maxHP
                                            end if
                                            if MP > maxMP then
                                                MP := maxMP
                                            end if
                                        else
                                            put "You cancelled."
                                        end if
                                    else
                                        put "You are not hungry right now."
                                    end if
                                    delay (2000)
                                label 8 :
                                    if Hunger < 90 then
                                        put "Would you like to eat cheese? It will refill 40% Hunger and restore 30% HP and MP."
                                        getch (keyinput)
                                        if keyinput = "y" or keyinput = "Y" then
                                            if cheese > 0 then
                                                cheese := cheese - 1
                                                Hunger := Hunger + 40
                                                HP := HP + round ((maxHP / 10) * 3)
                                                MP := MP + round ((maxMP / 10) * 3)
                                                put "You ate the cheese! Your hunger has been refilled!"
                                                fork BurpSound
                                            else
                                                put "You don't have any cheese!"
                                            end if
                                            if Hunger > 100 then
                                                Hunger := 100
                                            end if
                                            if HP > maxHP then
                                                HP := maxHP
                                            end if
                                            if MP > maxMP then
                                                MP := maxMP
                                            end if
                                        else
                                            put "You cancelled."
                                        end if
                                    else
                                        put "You are not hungry right now."
                                    end if
                                    delay (2000)
                                label 9 :
                                    if Hunger < 90 then
                                        put "Would you like to eat meat? It will refill 60% Hunger and restore 40% HP and MP."
                                        getch (keyinput)
                                        if keyinput = "y" or keyinput = "Y" then
                                            if meat > 0 then
                                                meat := meat - 1
                                                Hunger := Hunger + 60
                                                HP := HP + round ((maxHP / 10) * 4)
                                                MP := MP + round ((maxMP / 10) * 4)
                                                put "You ate the meat! Your hunger has been refilled!"
                                                fork BurpSound
                                            else
                                                put "You don't have any meat!"
                                            end if
                                            if Hunger > 100 then
                                                Hunger := 100
                                            end if
                                            if HP > maxHP then
                                                HP := maxHP
                                            end if
                                            if MP > maxMP then
                                                MP := maxMP
                                            end if
                                        else
                                            put "You cancelled."
                                        end if
                                    else
                                        put "You are not hungry right now."
                                    end if
                                    delay (2000)
                                label 0 :
                                    put "Returning..."
                            end case
                        else
                            put "Illegal input. Please enter numbers."
                            delay (1000)
                        end if
                        exit when keyinput = intstr (0)
                    end loop

                label 3 :
                    cls
                    Stats
                    put "Iron Ore: " : 15, 0 : 3, "" : 3, "Iron Ingot: " : 15, 0 : 3
                    put "Silver Ore: " : 15, 0 : 3, "" : 3, "Silver Ingot: " : 15, 0 : 3
                    put "Gold Ore: " : 15, 0 : 3, "" : 3, "Gold Ingot: " : 15, 0 : 3
                    put "Mithril Ore: " : 15, 0 : 3, "" : 3, "Mithril Ingot: " : 15, 0 : 3
                    put "Titanium Ore: " : 15, 0 : 3, "" : 3, "Titanium Ingot:" : 15, 0 : 3
                    put "Diamonds: " : 15, 0 : 3
                    put "Obsidian: " : 15, 0 : 3
                    put ""
                    put "Bones: " : 15, 0 : 3
                    put "Chitin: " : 15, 0 : 3
                    put "Spider Silk: " : 15, 0 : 3
                    put "Demon Essence: " : 15, 0 : 3
                label 4 :
                    if Heal = 0 then
                        put "You don't have heal spell available!"
                    elsif Heal = 1 then
                        if MP >= 4 then
                            MP := MP - 4
                            HP := HP + (10 + MPwr)
                            put "You have restored ", (10 + MPwr), " HP!"
                        else
                            put "Insufficient Mana!"
                        end if
                    elsif Heal = 2 then
                        if MP >= 7 then
                            MP := MP - 7
                            HP := HP + (20 + MPwr * 2)
                            put "You have restored ", (20 + MPwr * 2), " HP!"
                        else
                            put "Insufficient Mana!"
                        end if
                    elsif Heal = 3 then
                        if MP >= 10 then
                            MP := MP - 10
                            HP := HP + (40 + MPwr * 4)
                            put "You have restored ", (40 + MPwr * 4), " HP!"
                        else
                            put "Insufficient Mana!"
                        end if
                    end if
                label :
                    put "Invalid selection"
            end case
        else
            put "Illegal input"
        end if
        exit when keyinput = intstr (0)
    end loop
    if weapon not= "None" then
        Pic.Free (weaponPic)                     % Removes weapon picture from memory.
    end if
    if armour not= "None" then
        Pic.Free (armourPic)                     % Removes armour picture from memory.
    end if
    Pic.Free (charPic)                     % Removes character picture from memory.
    Pic.Free (BG)
    main
end FullStats

procedure InitializeCombat
    if timeOfDay >= 6 and timeOfDay < 22 then
        isEnemyRandom := true
        Combat
    else
        put "It's too late for combat now. Get some good sleep!"
    end if
end InitializeCombat
procedure ExitDungeon
    isExitingDungeon := true
end ExitDungeon

procedure Dungeon
    loop
        if dungeonX = dungeonExitX and dungeonY = dungeonExitY and dungeonZ = dungeonExitZ then
            canExitDungeon := true
        else
            canExitDungeon := false
        end if
        loop
            locate (1, 1)
            put "Location: ", dungeonX, ", ", dungeonZ, " | Floor: ", dungeonY
            Mouse.Where (x, y, button)
            if canUp = true then
                Pic.Draw (btnSmallPic, 025, 100, picCopy)
                if x >= 025 and x <= 125 and y >= 100 and y <= 150 then
                    Pic.Draw (btnSmallOverPic, 025, 100, picCopy)
                else
                    Pic.Draw (btnSmallPic, 025, 100, picCopy)
                end if
                Font.Draw ("Up", 042, 113, LargeComicFont, black)
                Font.Draw ("Up", 040, 115, LargeComicFont, white)
            end if
            if canDown = true then
                Pic.Draw (btnSmallPic, 275, 100, picCopy)
                if x >= 275 and x <= 375 and y >= 100 and y <= 150 then
                    Pic.Draw (btnSmallOverPic, 275, 100, picCopy)
                else
                    Pic.Draw (btnSmallPic, 275, 100, picCopy)
                end if
                Font.Draw ("Down", 292, 113, LargeComicFont, black)
                Font.Draw ("Down", 290, 115, LargeComicFont, white)
            end if
            if canNorth = true then
                Pic.Draw (btnSmallPic, 150, 100, picCopy)
                if x >= 150 and x <= 250 and y >= 100 and y <= 150 then
                    Pic.Draw (btnSmallOverPic, 150, 100, picCopy)
                else
                    Pic.Draw (btnSmallPic, 150, 100, picCopy)
                end if
                Font.Draw ("North", 162, 113, LargeComicFont, black)
                Font.Draw ("North", 160, 115, LargeComicFont, white)
            end if
            if canSouth = true then
                Pic.Draw (btnSmallPic, 150, 025, picCopy)
                if x >= 150 and x <= 250 and y >= 025 and y <= 075 then
                    Pic.Draw (btnSmallOverPic, 150, 025, picCopy)
                else
                    Pic.Draw (btnSmallPic, 150, 025, picCopy)
                end if
                Font.Draw ("South", 162, 038, LargeComicFont, black)
                Font.Draw ("South", 160, 040, LargeComicFont, white)
            end if
            if canWest = true then
                Pic.Draw (btnSmallPic, 025, 025, picCopy)
                if x >= 025 and x <= 125 and y >= 025 and y <= 075 then
                    Pic.Draw (btnSmallOverPic, 025, 025, picCopy)
                else
                    Pic.Draw (btnSmallPic, 025, 025, picCopy)
                end if
                Font.Draw ("West", 042, 038, LargeComicFont, black)
                Font.Draw ("West", 040, 040, LargeComicFont, white)
            end if
            if canEast = true then
                Pic.Draw (btnSmallPic, 275, 025, picCopy)
                if x >= 275 and x <= 375 and y >= 025 and y <= 075 then
                    Pic.Draw (btnSmallOverPic, 275, 025, picCopy)
                else
                    Pic.Draw (btnSmallPic, 275, 025, picCopy)
                end if
                Font.Draw ("East", 292, 038, LargeComicFont, black)
                Font.Draw ("East", 290, 040, LargeComicFont, white)
            end if
            if canExitDungeon = true then
                Pic.Draw (btnSmallPic, 400, 025, picCopy)
                if x >= 400 and x <= 500 and y >= 025 and y <= 075 then
                    Pic.Draw (btnSmallOverPic, 400, 025, picCopy)
                else
                    Pic.Draw (btnSmallPic, 400, 025, picCopy)
                end if
                Font.Draw ("Exit", 417, 038, LargeComicFont, black)
                Font.Draw ("Exit", 415, 040, LargeComicFont, white)
            end if
            delay (50)
            % Up
            exit when button not= 0 and x >= 025 and x <= 125 and y >= 100 and y <= 150
            % North
            exit when button not= 0 and x >= 150 and x <= 250 and y >= 100 and y <= 150
            % Down
            exit when button not= 0 and x >= 275 and x <= 375 and y >= 100 and y <= 150
            % West
            exit when button not= 0 and x >= 025 and x <= 125 and y >= 025 and y <= 075
            % South
            exit when button not= 0 and x >= 150 and x <= 250 and y >= 025 and y <= 075
            % East
            exit when button not= 0 and x >= 275 and x <= 375 and y >= 025 and y <= 075
            % Exit
            exit when button not= 0 and x >= 400 and x <= 500 and y >= 025 and y <= 075 and canExitDungeon = true

        end loop
        cls
        delay (250)
        if x >= 025 and x <= 125 and y >= 100 and y <= 150 and canUp then
            dungeonY := dungeonY + 1
        end if
        if x >= 150 and x <= 250 and y >= 100 and y <= 150 and canNorth then
            dungeonZ := dungeonZ + 1
        end if
        if x >= 275 and x <= 375 and y >= 100 and y <= 150 and canDown then
            dungeonY := dungeonY - 1
        end if
        if x >= 025 and x <= 125 and y >= 025 and y <= 075 and canWest then
            dungeonX := dungeonX - 1
        end if
        if x >= 150 and x <= 250 and y >= 025 and y <= 075 and canSouth then
            dungeonZ := dungeonZ - 1
        end if
        if x >= 275 and x <= 375 and y >= 025 and y <= 075 and canEast then
            dungeonX := dungeonX + 1
        end if
        if x >= 400 and x <= 500 and y >= 025 and y <= 075 and canExitDungeon then
            ExitDungeon
        end if
        if dungeonX >= dungeonSizeX then
            canEast := false
        else
            canEast := true
        end if
        if dungeonX <= 1 then
            canWest := false
        else
            canWest := true
        end if
        if dungeonZ >= dungeonSizeZ then
            canNorth := false
        else
            canNorth := true
        end if
        if dungeonZ <= 1 then
            canSouth := false
        else
            canSouth := true
        end if
        exit when isExitingDungeon = true
    end loop
end Dungeon

procedure CheckQuest
    if storyProgress = 1 then     % First main quest
        if level >= 5 then
            Quest1Start
        end if
    elsif storyProgress = 2 then
        Quest1Midway
    elsif storyProgress = 3 then
        Quest1End
        %elsif storyProgress = 4 then     % Second main quest
        %    if level >= 10 then
        %        Quest2Start
        %    end if
        %elsif storyProgress = 5 then
        %    Quest2Midway
        %elsif storyProgress = 6 then
        %    Quest1End
    else
        put "No quests available at this time."
    end if
end CheckQuest

procedure GoShopping
    if timeOfDay >= 6 and timeOfDay < 18 then
        Shop
    else
        put "The shop is closed."
    end if
end GoShopping

procedure QuitGame
    put "Would you like to save your progress? (yes/no)"
    colour (brightgreen)
    get cmd
    colour (white)
    if cmd = "y" or cmd = "Y" or cmd = "Yes" or cmd = "yes" then
        put "Saving..."
        SaveFile
    end if
    put "Goodbye!"
    isQuitting := true
    GUI.Quit
    delay (2000)
end QuitGame


% -- Menu Buttons --
Pic.Draw (btnPic, 25, 350, picCopy)     % Stats
Pic.Draw (btnPic, 25, 300, picCopy)     % Inn
Pic.Draw (btnPic, 25, 250, picCopy)     % Explore
Pic.Draw (btnPic, 25, 200, picCopy)     % Quest
Pic.Draw (btnPic, 25, 150, picCopy)     % Shop
Pic.Draw (btnPic, 25, 080, picCopy)     % Save button
Pic.Draw (btnPic, 25, 020, picCopy)     % Exit button

loop
    loop
        Mouse.Where (x, y, button)
        Pic.Draw (btnPic, 25, 350, picCopy)     % Stats
        Pic.Draw (btnPic, 25, 300, picCopy)     % Inn
        Pic.Draw (btnPic, 25, 250, picCopy)     % Explore
        Pic.Draw (btnPic, 25, 200, picCopy)     % Quest
        Pic.Draw (btnPic, 25, 150, picCopy)     % Shop
        Pic.Draw (btnPic, 25, 080, picCopy)     % Save button
        Pic.Draw (btnPic, 25, 020, picCopy)     % Exit button

        % Exit
        if x >= 25 and x <= 225 and y >= 20 and y <= 70 then
            Pic.Draw (btnOverPic, 25, 020, picCopy)
        else
            Pic.Draw (btnPic, 25, 020, picCopy)
        end if

        % Save
        if x >= 25 and x <= 225 and y >= 80 and y <= 130 then
            Pic.Draw (btnOverPic, 25, 080, picCopy)
        else
            Pic.Draw (btnPic, 25, 080, picCopy)
        end if

        % Shop
        if x >= 25 and x <= 225 and y >= 150 and y <= 200 then
            Pic.Draw (btnOverPic, 25, 150, picCopy)
        else
            Pic.Draw (btnPic, 25, 150, picCopy)
        end if

        % Quest
        if x >= 25 and x <= 225 and y >= 200 and y <= 250 then
            Pic.Draw (btnOverPic, 25, 200, picCopy)
        else
            Pic.Draw (btnPic, 25, 200, picCopy)
        end if

        % Explore
        if x >= 25 and x <= 225 and y >= 250 and y <= 300 then
            Pic.Draw (btnOverPic, 25, 250, picCopy)
        else
            Pic.Draw (btnPic, 25, 250, picCopy)
        end if

        % Inn
        if x >= 25 and x <= 225 and y >= 300 and y <= 350 then
            Pic.Draw (btnOverPic, 25, 300, picCopy)
        else
            Pic.Draw (btnPic, 25, 300, picCopy)
        end if

        % Stats
        if x >= 25 and x <= 225 and y >= 350 and y <= 400 then
            Pic.Draw (btnOverPic, 25, 350, picCopy)
        else
            Pic.Draw (btnPic, 25, 350, picCopy)
        end if

        Font.Draw ("Stats", 37, 363, LargeComicFont, black)
        Font.Draw ("Inn", 37, 313, LargeComicFont, black)
        Font.Draw ("Explore", 37, 263, LargeComicFont, black)
        Font.Draw ("Quest", 37, 213, LargeComicFont, black)
        Font.Draw ("Shop", 37, 163, LargeComicFont, black)
        Font.Draw ("Save Game", 37, 93, LargeComicFont, black)
        Font.Draw ("Exit Game", 37, 33, LargeComicFont, black)

        Font.Draw ("Stats", 35, 365, LargeComicFont, white)
        Font.Draw ("Inn", 35, 315, LargeComicFont, white)
        Font.Draw ("Explore", 35, 265, LargeComicFont, white)
        Font.Draw ("Quest", 35, 215, LargeComicFont, white)
        Font.Draw ("Shop", 35, 165, LargeComicFont, white)
        Font.Draw ("Save Game", 35, 95, LargeComicFont, white)
        Font.Draw ("Exit Game", 35, 35, LargeComicFont, white)

        delay (50)
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 20 and y <= 70
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 80 and y <= 130
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 150 and y <= 200
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 200 and y <= 250
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 250 and y <= 300
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 300 and y <= 350
        exit when button not= 0 and x >= 25 and x <= 225 and y >= 350 and y <= 400
    end loop
    if x >= 25 and x <= 225 and y >= 20 and y <= 70 then
        QuitGame
    end if
    if x >= 25 and x <= 225 and y >= 80 and y <= 130 then
        SaveFile
    end if
    if x >= 25 and x <= 225 and y >= 150 and y <= 200 then
        GoShopping
    end if
    if x >= 25 and x <= 225 and y >= 200 and y <= 250 then
        CheckQuest
    end if
    if x >= 25 and x <= 225 and y >= 250 and y <= 300 then
        InitializeCombat
    end if
    if x >= 25 and x <= 225 and y >= 300 and y <= 350 then
        Inn
    end if
    if x >= 25 and x <= 225 and y >= 350 and y <= 400 then
        FullStats
    end if
    exit when isQuitting = true
end loop


% Shut down the game.
loop
    exit when GUI.ProcessEvent
end loop

Pic.Free (btnPic)
Pic.Free (btnOverPic)

Window.Close (w)
