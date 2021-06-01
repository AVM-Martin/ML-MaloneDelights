package app;

import jess.JessException;
import jess.Rete;

public class Main {
  public static Rete engine;

  public static void main(String[] args) {
    engine = new Rete();

    try {
      engine.batch("project.clp");
    } catch (JessException e) {
      e.printStackTrace();
    }
  }
}
