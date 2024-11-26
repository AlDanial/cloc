/*
based on
https://raw.githubusercontent.com/casella/ScalableTestSuite/master/ScalableTestSuite/Elementary/SimpleODE.mo

*/

within ScalableTestSuite.Elementary;
package SimpleODE "Models with simple ODE systems"
  package Models
    model CascadedFirstOrder
      "N cascaded first order systems, approximating a pure delay"
      parameter Integer N = 10 "Order of the system";
      parameter Modelica.Units.SI.Time T=1 "System delay";
      final parameter Modelica.Units.SI.Time tau=T/N "Individual time constant";
      Real x[N]( each start = 0, each fixed = true) "State array";
      Real u = 1 "Cascaded system input";
    equation
      tau*der(x[1]) = u - x[1];
      for i in 2:N loop
        tau*der(x[i]) = x[i-1] - x[i];
      end for;
    annotation(
      experiment(StopTime = 2,Tolerance = 1e-6),
      Documentation(info = "<html><p>This model is meant to try out  the tool
        performance with ODE systems of possibly very large size, with high
        sparsity degree.</p>
        <p> The model is a cascaded connection of first order linear systems,
        approximating a pure delay of <tt>T</tt> seconds as <tt>N</tt> approaches
        infinity. It contains exactly <tt>N</tt> state variables and <tt>N</tt>
        differential equations.</p></html>"));
    end CascadedFirstOrder;
  end Models;

  package ScaledExperiments
    model CascadedFirstOrder_N_100
      extends Models.CascadedFirstOrder(N=100);
    annotation(experiment(StopTime = 2, Tolerance = 1e-6),
               __OpenModelica_simulationFlags(s = "ida"));
    end CascadedFirstOrder_N_100;

//  model CascadedFirstOrder_N_200
//    extends Models.CascadedFirstOrder(N=200);
//  annotation(experiment(StopTime = 2, Tolerance = 1e-6),
//             __OpenModelica_simulationFlags(s = "ida"));
//  end CascadedFirstOrder_N_200;

    model CascadedFirstOrder_N_400
      extends Models.CascadedFirstOrder(N=400);
    annotation(experiment(StopTime = 2, Tolerance = 1e-6),
               __OpenModelica_simulationFlags(s = "ida"));
    end CascadedFirstOrder_N_400;

    model CascadedFirstOrder_N_25600
      extends Models.CascadedFirstOrder(N=25600);
    annotation(experiment(StopTime = 2, Tolerance = 1e-6),
               __OpenModelica_simulationFlags(s = "ida"));
    end CascadedFirstOrder_N_25600;
  end ScaledExperiments;
end SimpleODE;
