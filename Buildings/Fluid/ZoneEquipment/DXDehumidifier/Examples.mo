within Buildings.Fluid.ZoneEquipment.DXDehumidifier;
package Examples
    extends Modelica.Icons.ExamplesPackage;
  model SimpleInput
      extends Modelica.Icons.Example;
     package Medium = Buildings.Media.Air "Medium model";

    parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=0.1
      "Nominal mass flow rate";


    Buildings.Fluid.ZoneEquipment.DXDehumidifier.DXDehumidifier dxDeh(
      redeclare package Medium = Medium,
      m_flow_nominal=0.1,
      dp_nominal=0,
      m_flow(start=0.1),
      dp(start=10),
      per=per)
      annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.Ramp TIn(
      duration=7200,
      height=1,
      offset=273.15 + 25,
      startTime=7200) "Inlet temperature"
      annotation (Placement(transformation(extent={{-90,10},{-70,30}})));
    Modelica.Fluid.Sources.MassFlowSource_T sou(
      use_T_in=true,
      redeclare package Medium = Medium,
      m_flow=0.1,
      use_m_flow_in=false,
      nPorts=1) "Flow source"
      annotation (Placement(transformation(extent={{-46,-10},{-26,10}})));
    Data.Generic per
      annotation (Placement(transformation(extent={{40,62},{60,82}})));
    Modelica.Fluid.Sources.FixedBoundary sin1(
      redeclare package Medium = Medium, nPorts=1)
                "Sink"
           annotation (Placement(transformation(extent={{82,-10},{62,10}})));
    Modelica.Blocks.Sources.Ramp phi(
      final duration=7200,
      final height=-5,
      final offset=65)   "Relative humidity"
      annotation (Placement(transformation(extent={{-50,40},{-30,60}})));
    Modelica.Blocks.Sources.BooleanStep on(startTime=7200, startValue=true)
      annotation (Placement(transformation(extent={{-50,-50},{-30,-30}})));
  equation
    connect(TIn.y, sou.T_in)
      annotation (Line(points={{-69,20},{-56,20},{-56,4},{-48,4}},
                                                 color={0,0,127}));
    connect(phi.y, dxDeh.phi) annotation (Line(points={{-29,50},{-20,50},{-20,4},{
            -11,4}},color={0,0,127}));
    connect(dxDeh.port_a, sou.ports[1])
      annotation (Line(points={{-10,0},{-26,0}},color={0,127,255}));
    connect(on.y, dxDeh.uEna) annotation (Line(points={{-29,-40},{-18,-40},{-18,-4},
            {-11,-4}}, color={255,0,255}));
    connect(sin1.ports[1], dxDeh.port_b)
      annotation (Line(points={{62,0},{10,0}}, color={0,127,255}));
    connect(TIn.y, dxDeh.TIn) annotation (Line(points={{-69,20},{-18,20},{-18,6},
            {-11,6}}, color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)),
      experiment(StopTime=14400, __Dymola_Algorithm="Cvode"),
      __Dymola_Commands(file="Resources/Scripts/Dymola/Fluid/ZoneEquipment/DXDehumidifier/Examples/SimpleInput.mos"
          "Simulate and Plot"));
  end SimpleInput;
end Examples;
