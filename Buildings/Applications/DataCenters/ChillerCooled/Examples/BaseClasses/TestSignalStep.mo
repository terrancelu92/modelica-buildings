within Buildings.Applications.DataCenters.ChillerCooled.Examples.BaseClasses;
model TestSignalStep
  SignalStep signalStep[4](randomSeed={1,20,300,4000}, usePredefPattern=false)
    annotation (Placement(transformation(extent={{-10,-12},{10,8}})));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=21600, __Dymola_Algorithm="Dassl"));
end TestSignalStep;
