import java.util.ArrayList;

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