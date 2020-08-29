OPTION _EXPLICIT 'Makes the compiler throw an error when an undeclared variable appears

_TITLE "IB Scheduling Helper by jojo2357" 'title the .exe window

IF _FILEEXISTS("Schedules.txt") THEN 'if the file exists, open it to be read, else print an error and end the program
    OPEN "Schedules.txt" FOR INPUT AS #1
ELSE
    PRINT "Schedules.txt: FILE NOT FOUND"
    END
END IF

DIM Titles(1 TO 100) AS STRING 'names of students
DIM numOfClasses(1 TO 100) AS _UNSIGNED _BYTE 'number of classes each student is taking
DIM Classes(1 TO 100, 1 TO 10) AS STRING 'indexes : (Student, class) = name of class
DIM ClassIndex(1 TO 100, 1 TO 10) AS _UNSIGNED _BYTE '(Student, class) = index of class in [founds]
DIM foUnds(1 TO 25) AS STRING 'Every class in order found
DIM Period(0 TO 10) AS _UNSIGNED _BYTE '(Period in the day) = class index
DIM possiblePeriods(1 TO 25, 0 TO 6) AS _UNSIGNED _BYTE '(Class Index, Period in question) = yes, this class can go in this period / no, this class can't go here
DIM indexes(0 TO 10) AS _UNSIGNED _BYTE 'in schedule calculation, points to the index in founds that the class at index () in classes [,()]
DIM bestIndex(0 TO 6) AS STRING 'holds the name of each class in a record-setting best solution. Indexed in the same order as read
DIM best(0 TO 6) AS _UNSIGNED _BYTE 'holds the period for each class in a record-setting best solution. ^

'Every variable declared here, despite not having to. They're pretty much all the same and the names can usually be understood in their own context

DIM classfinder
DIM LineIn$ 'the $ denotes a string variable
DIM Possibles$
DIM ClassIn$
DIM all$
DIM good AS _UNSIGNED _BIT 'in QB, a bit is 0 or -1, false/true, but for simplicity, positive values are used
DIM fail AS _UNSIGNED _BIT
DIM gotit AS _UNSIGNED _BIT
DIM position AS _UNSIGNED INTEGER
DIM personFinder AS _UNSIGNED INTEGER
DIM foundpos AS _UNSIGNED _BYTE
DIM FindIt AS _UNSIGNED _BYTE
DIM PeriodIn AS _UNSIGNED _BYTE
DIM Fill AS _UNSIGNED _BYTE
DIM testFind AS _UNSIGNED _BYTE
DIM i AS _UNSIGNED _BYTE
DIM amtOfPeriods AS _UNSIGNED _BYTE
DIM amtOfClasses AS _UNSIGNED _BYTE
DIM classChecker AS _UNSIGNED _BYTE
DIM allChoices AS _UNSIGNED _BYTE
DIM thisRecord AS _UNSIGNED _BYTE
DIM classGrabber AS _UNSIGNED _BYTE
DIM periodClear AS _UNSIGNED _BYTE
DIM innerLoop AS _UNSIGNED _BYTE
DIM conflicts AS _UNSIGNED _BYTE
DIM tester AS _UNSIGNED _BYTE
DIM otherTest AS _UNSIGNED _BYTE
DIM numTot AS _UNSIGNED _BYTE
DIM q AS _UNSIGNED _BYTE
DIM increase AS _UNSIGNED _BYTE
DIM periodFinder AS _UNSIGNED _BYTE

foundpos = 1 'foundpos is the amount of classes found + 1

DO
    position = position + 1 'position represents the amount of students read
    LINE INPUT #1, LineIn$ 'read line from txt file
    LineIn$ = UCASE$(LTRIM$(RTRIM$(LineIn$ + ","))) 'make everything uppercase and remove leading and trailing spaces
    Titles(position) = LEFT$(LineIn$, INSTR(LineIn$, ",") - 1) 'assign up to the first comma to the appropriate index of names
    LineIn$ = RTRIM$(LTRIM$(RIGHT$(LineIn$, LEN(LineIn$) - INSTR(LineIn$, ",")))) 'tidy up the remaining data and remove the leading name
    classfinder = 0 'classfinder is the amount of classes found for a given student
    DO
        classfinder = classfinder + 1
        IF classfinder = 11 THEN 'if it has found 11 classes, then something is wrong so to prevent a banana loop
            PRINT ":" + LineIn$ + ":" ' show the remaining data
            PRINT "ERROR"
            END 'stop the program
        END IF
        Classes(position, classfinder) = LTRIM$(RTRIM$(LEFT$(LineIn$, INSTR(LineIn$, ",") - 1))) 'add up to the next comma, omitting leading and trailing spaces, to the class list for the current student
        good = 0
        FOR classChecker = 1 TO foundpos - 1 'loop thru every found class
            IF foUnds(classChecker) = Classes(position, classfinder) THEN 'if the class just found in this student's schedule is already found, set good to true
                good = 1
                ClassIndex(position, classfinder) = classChecker 'with the index of the class found, the corresponding classIndex can be assigned
            END IF
        NEXT
        IF good = 0 THEN 'if good - false
            foUnds(foundpos) = Classes(position, classfinder) 'add a new class to foUnds
            ClassIndex(position, classfinder) = foundpos
            foundpos = foundpos + 1
        END IF
        LineIn$ = RTRIM$(LTRIM$(RIGHT$(LineIn$, LEN(LineIn$) - INSTR(LineIn$, ",")))) 'tidy up the data and remove the class that was just found
    LOOP UNTIL LineIn$ = "" 'loop until there is no more data (classes) to be extracted
    numOfClasses(position) = classfinder
LOOP UNTIL EOF(1) 'loop until the last line has been read

CLOSE #1

PRINT "READ FROM SCHEDULES:"

DIM p

FOR p = 1 TO position
    PRINT Titles(p)
NEXT
FOR p = 1 TO foundpos - 1
    PRINT foUnds(p)
NEXT

OPEN "Conflicts.txt" FOR OUTPUT AS #2 'OPEN will create the file if it doesn't exist or clear it if it does already but will not open it the same way a user does.
'This file is the output file where all output will go. PRINT #2, means "add a line to Conflicts.txt that contains..."

IF _FILEEXISTS("ClassChances.txt") THEN

    'DIM internalClock
    'internalClock = _FREETIMER
    'ON TIMER(internalClock, 60) GOSUB fail
    'TIMER(internalClock) ON 'create a timer that, every 60 seconds, will go to the line that starts with fail: (found at the end of program)
    'By nature, this will only run once and is a safeguard against dragging down cpu whilst in background
    'this moves the exe to the background because no more user input is required
    OPEN "ClassChances.txt" FOR INPUT AS #3 'opens the file for extracting class period data
    PRINT #2, "Schedule gathered from file: "
    DO
        LINE INPUT #3, LineIn$ 'Read data
        Possibles$ = "" 'Possibles holds all of the class periods so that it can be printed to the output file
        ClassIn$ = UCASE$(LEFT$(LineIn$, INSTR(LineIn$, ":") - 1)) 'Gathers the class name that was just read
        LineIn$ = LTRIM$(RTRIM$(RIGHT$(LineIn$, LEN(LineIn$) - INSTR(LineIn$, ":")))) 'Contains the rest of the line, ie. all of the possible periods for a class
        FOR FindIt = 1 TO foundpos - 1 'for every class on record:
            IF ClassIn$ = foUnds(FindIt) THEN 'if the test class is the class just read
                IF INSTR(LineIn$, ",") THEN 'if there is a comma, the do loop will work as intended and will go through
                    DO
                        IF INSTR(LineIn$, ",") THEN 'while there is a comma left in the data, keep extracting and recording possible class periods
                            PeriodIn = VAL(LEFT$(LineIn$, INSTR(LineIn$, ",")))
                            possiblePeriods(FindIt, PeriodIn) = 1
                            LineIn$ = MID$(LineIn$, INSTR(LineIn$, ",") + 1)
                            LineIn$ = LTRIM$(RTRIM$(LineIn$))
                        ELSE 'if there are no more commas, there must only be one more number
                            PeriodIn = VAL(LineIn$)
                            possiblePeriods(FindIt, PeriodIn) = 1
                            EXIT DO 'exits the do...loop. Yes this is bad practice, but hey, if it works, it works
                        END IF
                    LOOP
                ELSE 'if there are no commas, there are two possibilities: one period or all periods
                    IF LEN(LineIn$) = 0 THEN 'if there is only spaces as they were taken out earlier,
                        FOR Fill = 0 TO 6
                            possiblePeriods(FindIt, Fill) = 1 'every period is possible for this class
                        NEXT
                    ELSE
                        possiblePeriods(FindIt, VAL(LineIn$)) = 1 'if there is only one number, only that period is set to true
                    END IF
                END IF
                FOR testFind = 0 TO 6
                    IF possiblePeriods(FindIt, testFind) = 1 THEN
                        Possibles$ = Possibles$ + STR$(testFind) + ", " 'gather every possible period in Possibles$
                    END IF
                NEXT
                PRINT #2, ClassIn$ + ": " + Possibles$ 'Print to the output file the class name and every period that it can go
            END IF
        NEXT
    LOOP UNTIL EOF(3) 'Loop until all data collected. PROGRAM WILL NOT WORK AS INTENDED IF CLASSES OMITTED
ELSE
    FOR i = 1 TO foundpos - 1 'For every class, gather data about each class from the user
        PRINT "How Many periods will "; foUnds(i); " be able to go?"
        INPUT amtOfPeriods 'if the user says that the class can go 7 periods, the computer knows to auto-assign the possible periods
        IF amtOfPeriods < 7 THEN
            PRINT "Please enter a period for "; foUnds(i); " and press enter after each"
            all$ = "" 'all$ collects every possible period the class can go
            FOR amtOfClasses = 1 TO amtOfPeriods
                INPUT PeriodIn
                possiblePeriods(i, Period(i)) = 1
                all$ = all$ + LTRIM$(STR$(PeriodIn)) + ", "
            NEXT
            PRINT #2, foUnds(i); " is had the following periods: "; all$
        ELSE
            all$ = ""
            FOR allChoices = 0 TO 6
                possiblePeriods(i, allChoices) = 1
                all$ = all$ + LTRIM$(STR$(allChoices))
            NEXT
            PRINT #2, foUnds(i); " is had the following periods: "; all$
        END IF
    NEXT
END IF

'The following is the algorithm to find for each student an opitimal schedule. It is confusing even to me and i have to explain it to myself.
'The algorithm is brute force, and tries every possible permutation of classes without creating new ones, only ones that the user has previously permitted
'The array Period is 0 indexed and can be read as: Period(index of class in orig. req) = tenetive period for said class
'The array indexes is also 0 indexed and while not required, replaces classindex, a 2-D array that takes up more space on the page and is 1 indexed. It is read as:
'indexes(index of class in orig. req) = index in foUnds

FOR personFinder = 1 TO position 'for every person:
    PRINT "Starting person "; Titles(personFinder)
    thisRecord = 10
    FOR classGrabber = 1 TO numOfClasses(personFinder)
        indexes(classGrabber - 1) = ClassIndex(personFinder, classGrabber)
    NEXT
    FOR periodClear = 0 TO 6
        Period(periodClear) = 0
    NEXT
    keepGoing:
    FOR innerLoop = 0 TO 6
        IF possiblePeriods(indexes(numOfClasses(personFinder) - 1), innerLoop) = 0 THEN _CONTINUE
        Period(numOfClasses(personFinder) - 1) = innerLoop
        fail = 0
        conflicts = 0
        FOR tester = 0 TO numOfClasses(personFinder) - 2
            FOR otherTest = tester + 1 TO numOfClasses(personFinder) - 1
                IF possiblePeriods(indexes(tester), Period(tester)) = 0 OR possiblePeriods(indexes(otherTest), Period(otherTest)) = 0 THEN 'if a class is tenetively in a                           period for which it cannot go, then go to the next test
                    GOTO stepNext
                END IF
                IF Period(tester) = Period(otherTest) THEN
                    conflicts = conflicts + 1
                    fail = 1 'fail is essentially boolean for is there has been ANY conflict
                END IF
            NEXT
        NEXT
        IF conflicts < thisRecord THEN 'this is meant to set the arrays best and bestIndex to the data they are meant to hold when conflicts are minimized
            thisRecord = conflicts
            numTot = 0
            FOR q = 0 TO numOfClasses(personFinder) - 1
                best(q) = Period(q)
                bestIndex(q) = foUnds(indexes((q)))
            NEXT
        END IF
        IF fail = 0 THEN 'However, if there was a perfect solution, output it and move on
            PRINT #2, "No Conflict Schedule found! "; Titles(personFinder)
            FOR q = 0 TO numOfClasses(personFinder)
                IF indexes(q) > 0 THEN 'error protection
                    best(q) = Period(q)
                    bestIndex(q) = foUnds(indexes(q))
                END IF
            NEXT
            GOTO pass
        END IF
    NEXT
    stepNext:
    FOR increase = numOfClasses(personFinder) - 2 TO 0 STEP -1 'for every class, less the one covered by innerLoop, running in reverse
        Period(increase) = Period(increase) + 1 'step 1
        IF Period(increase) = 7 THEN 'if out of bounds (overflow)
            Period(increase) = 0
            DO
                Period(increase) = Period(increase) + 1 'step 1 until a possible period is found and then go onto the next class
                IF Period(increase) > 6 THEN Period(increase) = 0
            LOOP UNTIL possiblePeriods(indexes(increase), Period(increase)) = 1
        ELSE GOTO keepGoing 'if not overflow, a new permutation is found and must be tried but the person kept                    the same. This will take the program to execute from the line keepGoing:
        END IF
    NEXT

    pass:
    PRINT #2, Titles(personFinder) 'outputs all of the data when an optimal solution is found or Period(0) overflows                     and fails to run GOTO keepGoing, signaling all perms tested
    FOR periodClear = 0 TO 6
        gotit = 0
        FOR periodFinder = 0 TO numOfClasses(personFinder) - 1
            IF periodClear = best(periodFinder) THEN
                PRINT #2, periodClear; ": "; bestIndex(periodFinder)
                gotit = 1
            END IF
        NEXT
        IF gotit = 0 THEN
            PRINT #2, periodClear; ": FREE"
        END IF
    NEXT
NEXT

SHELL _DONTWAIT "Conflicts.txt" 'Open for the user and then immediately move on without waiting for user to close                     file before moving on to
SYSTEM 'Forcibly close exe tab

fail: 'After 60 seconds of running, quit and add to output file following message
PRINT #2, "An error has occured and the program has forced its own exit."
PRINT #2, "This is a built in safety feature that occurs after 60 seconds"
SHELL _DONTWAIT "Conflicts.txt"
SYSTEM
