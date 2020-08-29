import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

public class JavaSchedulerMain {
    public static void main(String args[]) throws IOException{
        long timeIn = System.currentTimeMillis();
        byte classesFound = 0;
        int solvedKids = 0;

        ArrayList<Student> students = new ArrayList<Student>();
        ArrayList<Class> classes = new ArrayList<Class>();

        String cwd = System.getProperty("user.dir");

        File classInputFile = new File(cwd + File.separator + "ClassChances.txt");
        if (!classInputFile.exists()) {
            onInputNotFound();
            return;
        }
        Scanner classInputReader = new Scanner(classInputFile);//normal scanner object, except reading from a file
        /*
        * GATHER CLASSES AND CLASS PERIODS
        */
        do{
            String[] dataIn = classInputReader.nextLine().toUpperCase().split(", ");
            if (dataIn.length == 0){
                onFileReadError(classesFound);
                return;
            }
            Class classBuilder = new Class(dataIn[0], dataIn);
            classes.add(classBuilder);
            classesFound++;
        }while (classInputReader.hasNextLine());
        classInputReader.close();

        File studentsFile = new File(cwd + File.separator + "Schedules.txt");
        if (!studentsFile.exists()){
            onInputNotFound();
            return;
        }
        Scanner studentDataReader = new Scanner(studentsFile);
        /*
        * GATHER STUDENT AND CLASS REQUESTS
        */
        do{
            String[] dataIn = studentDataReader.nextLine().toUpperCase().split(", ");
            if (dataIn.length == 0){
                onFileReadError(classesFound);
                return;
            }
            ArrayList<Class> classBuilder = new ArrayList<Class>();
            /*
            * for each class the student requested, we need to find the corresponding Class object
            * once found, it gets added to the list of classes that the student asked for
            */
            for (int i = 1; i < dataIn.length; i++){
                for (Class klass : classes){
                    if (klass.toString().equals(dataIn[i])){
                        classBuilder.add(klass);
                        break;
                    }
                }
            }
            students.add(new Student(dataIn[0], classBuilder));
        }while (studentDataReader.hasNextLine());
        studentDataReader.close();

        File output = new File(cwd + File.separator + "Conflicts.txt");
        if (!output.exists()) output.createNewFile();
        FileWriter outputWriter = new FileWriter(output);

        for (int studentIndex = 0; studentIndex < students.size(); studentIndex++){

            Student student = students.get(studentIndex);
            int recordConflicts = 10;

            int[] tenetivePeriods = new int[student.classesRequested()];
            int[] recordPeriods = new int[student.classesRequested()];

            for (int checkSingles = 0; checkSingles < student.classesRequested(); checkSingles++){
                if (!student.classRequests.get(checkSingles).periodsOffered.contains((byte)tenetivePeriods[checkSingles])){
                    do{//do...until period for [checkSingles]th class is in a valid period
                        tenetivePeriods[checkSingles]++;
                    }while (!student.classRequests.get(checkSingles).periodsOffered.contains((byte)tenetivePeriods[checkSingles]));
                }
                if (student.classRequests.get(checkSingles).singlePeriod) tenetivePeriods[checkSingles] = student.classRequests.get(checkSingles).periodsOffered.get(0);
            }

            Boolean solveableFlag;
            do{
                solveableFlag = true;
                int currentConflicts = 0;

                for (int checkAndCountConflictsOutter = 0; checkAndCountConflictsOutter < tenetivePeriods.length; checkAndCountConflictsOutter++){
                    for (int checkAndCountConflictsInner = checkAndCountConflictsOutter + 1; checkAndCountConflictsInner < tenetivePeriods.length; checkAndCountConflictsInner++){
                        if (tenetivePeriods[checkAndCountConflictsOutter] == tenetivePeriods[checkAndCountConflictsInner]){
                            currentConflicts++;
                        }
                    }
                }

                if (currentConflicts < recordConflicts){
                    recordConflicts = currentConflicts;
                    recordPeriods = tenetivePeriods.clone();
                }

                for (int classStepper = 0; classStepper < student.classesRequested(); classStepper++){
                    boolean overflowFlag = false;

                    if (student.classRequests.get(classStepper).singlePeriod) {
                        continue;
                    }

                    tenetivePeriods[classStepper]++;

                    if (tenetivePeriods[classStepper] >= 7){
                        overflowFlag = true;
                        tenetivePeriods[classStepper] = 0;
                    }

                    if (!student.classRequests.get(classStepper).periodsOffered.contains((byte)tenetivePeriods[classStepper])){
                        do{
                            tenetivePeriods[classStepper]++;

                            if (tenetivePeriods[classStepper] >= 7){
                                overflowFlag = true;
                                tenetivePeriods[classStepper] = 0;
                            }
                        }while (!student.classRequests.get(classStepper).periodsOffered.contains((byte)tenetivePeriods[classStepper]));
                    }

                    if (!overflowFlag) break;

                    if (classStepper == student.classesRequested() - 1) 
                        solveableFlag = false;
                }
            }while (recordConflicts > 0 && solveableFlag);
            /*
            * At this point, schedule is either conflict-free, or it cannot be so. 
            * Either way, we output here:
            */
            if (recordConflicts == 0) 
                solvedKids++;

            outputWriter.append("Best solution found for " + student + (recordConflicts > 0 ? " (" + recordConflicts + ")" : "") +'\n');
            
            for (int schedulePrinter = 0; schedulePrinter < 7; schedulePrinter++){
                boolean classPrintedFlag = false;

                for (int classFinder = 0; classFinder < student.classesRequested(); classFinder++){
                    if (recordPeriods[classFinder] == schedulePrinter) {
                        outputWriter.append(schedulePrinter + ": " + student.classRequests.get(classFinder) + '\n');
                        classPrintedFlag = true;
                    }
                }

                if (!classPrintedFlag) //Didn't print a class, must be Fuh-ree!
                    outputWriter.append(schedulePrinter + ": " + "FREE" + '\n');
            }
            outputWriter.append('\n');
        }
        outputWriter.close();
        System.out.println("Finished in " + (System.currentTimeMillis() - timeIn) + " ms and found " + solvedKids + " no conflict solutions out of " + students.size() + " possible schedules");
        Runtime.getRuntime().exec("Notepad.exe Conflicts.txt"); //Opens notepad with the output file open
    }

    private static void onFileReadError(byte classesFound) {
        System.out.println("Error reading line " + (classesFound + 1) + " of the classes file");
    }

    private static void onInputNotFound() {
        System.out.println(System.getProperty("user.dir") + File.separator + "  an essential file could not be found in this directory");
    }
}

class Class{

    public Boolean singlePeriod = false;
    public ArrayList<Byte> periodsOffered = new ArrayList<Byte>();
    private String name;

    public Class (String name, String[] offered){
        if (offered.length > 1){
            for (Byte i = (byte)(offered.length - 1); i > 0; i--)
                periodsOffered.add((byte)Integer.parseInt(offered[i]));
        }else{
            for (Byte i = 6; i >= 0; i--)
                periodsOffered.add(i);
        }
        this.name = name;
        if (periodsOffered.size() == 1) singlePeriod = true;
    }

    public String toString(){
        return this.name;
    }
}

class Student{

    private String name;
    public ArrayList<Class> classRequests = new ArrayList<Class>();

    public Student (String name, ArrayList<Class> requests){
        this.name = name;
        for (Byte i = (byte)(requests.size() - 1); i >= 0; i--)
            this.classRequests.add(requests.get(i));
    }

    public String getName(){
        return this.name;
    }

    public int classesRequested(){
        return this.classRequests.size();
    }

    public String toString(){
        return this.name;
    }
}