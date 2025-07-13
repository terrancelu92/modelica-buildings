within Buildings.Applications.DataCenters.ChillerCooled.Examples.BaseClasses;
model SignalStep
  "Generalized step-changing random signal generator with uniform distributionGeneralized step-changing random signal generator with uniform distribution"
  // Parameters
  parameter Real yMin = 12.8 "Minimum output value";
  parameter Real yMax = 20.0 "Maximum output value";
  parameter Real sampleTime = 180 "Sample time in seconds";
  parameter Integer randomSeed = 1 "Random seed for reproducibility";
  parameter Boolean usePredefPattern = true "Use predefined pattern for better coverage";
  parameter Integer patternLength = 10 "Length of predefined pattern";

  // Derived parameters
  parameter Real range = yMax - yMin "Output range";
  parameter Real[10] pattern = {0.1, 0.9, 0.3, 0.7, 0.5, 0.2, 0.8, 0.6, 0.4, 0.0} "Predefined pattern for uniform coverage";

  // Output connector
  Modelica.Blocks.Interfaces.RealOutput y "Output signal"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));

  // Internal variables
  Integer stepIndex "Current step index";
  Real normalizedValue "Normalized value [0,1]";

equation
  // Calculate step index directly from time
  stepIndex = integer(mod(floor(time/sampleTime), patternLength));

  // Generate normalized value based on selected method
  if usePredefPattern then
    // Use predefined pattern for guaranteed uniform coverage
    normalizedValue = pattern[stepIndex + 1] +
                     0.05 * sin(2*3.14159*floor(time/sampleTime)*0.234 + randomSeed);
  else
    // Use pseudo-random generation
    normalizedValue = mod(floor(time/sampleTime) * 1664525 + 1013904223 + randomSeed * 997, 2^20) / 2^20;
  end if;

  // Calculate final output (ensuring bounds)
  y = yMin + range * max(0, min(1, normalizedValue));

  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                  Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{130,102},{-126,154}},
          textColor={0,0,255},
          textString="%name")}),                                 Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StartTime=972000,
      StopTime=1015200,
      __Dymola_Algorithm="Dassl"));
end SignalStep;
