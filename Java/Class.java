import java.util.ArrayList;

public class Class{

    public Boolean singlePeriod = false;
    public ArrayList<Byte> periodsOffered = new ArrayList<Byte>();
    private String name;

    public Class (String name, String[] offered){
        if (offered.length > 1){
            for (byte i = (byte)(offered.length - 1); i > 0; i--) {
                if (offered[i].trim().length() > 0)
                    periodsOffered.add((byte) Integer.parseInt(offered[i].trim()));
            }
        }else{
            for (byte i = 6; i >= 0; i--)
                periodsOffered.add(i);
        }
        this.name = name;
        if (periodsOffered.size() == 1) singlePeriod = true;
    }

    public String toString(){
        return this.name;
    }
}
