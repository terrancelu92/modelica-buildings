within Buildings.Templates.Components.Valves;
model ThreeWay "Three-way valve"
  extends Buildings.Templates.Components.Valves.Interfaces.PartialValve(
    final typ=Buildings.Templates.Components.Types.Valve.ThreeWay);

  replaceable Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear val(
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    constrainedby Buildings.Fluid.Actuators.BaseClasses.PartialThreeWayValve(
      redeclare final package Medium=Medium,
      final m_flow_nominal=m_flow_nominal,
      final dpValve_nominal=dpValve_nominal,
      final dpFixed_nominal={dpFixed_nominal, dpFixedByp_nominal})
    "Valve"
    annotation (
      choicesAllMatching=true,
      Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0)));
equation
  connect(y, val.y);
  connect(port_a, val.port_1)
    annotation (Line(points={{-100,0},{-10,0}}, color={0,127,255}));
  connect(val.port_2, port_b)
    annotation (Line(points={{10,0},{100,0}}, color={0,127,255}));
  connect(val.port_3, portByp_a)
    annotation (Line(points={{0,-10},{0,-100}}, color={0,127,255}));
  annotation (Documentation(info="<html>
By default, the nominal pressure drop dpFixed_nominal 
in the bypass line is considered
equal to the one in the direct line.
</html>"));
end ThreeWay;