within Buildings.Templates.Components.OutdoorAirMixer;
model OutdoorAirMixer "Outdoor Air Mixer"
  extends
    Buildings.Templates.Components.OutdoorAirMixer.Interfaces.PartialOutdoorAirMixer(
    final typDamOut=damOut.typ,
    final typDamRel=damRel.typ,
    final typDamRet=damRet.typ,
    final have_eco=false,
    final have_recHea=false);


  Buildings.Templates.Components.Dampers.PressureIndependent damOut(
    redeclare final package Medium = MediumAir,
    final dat=dat.damOut,
    final text_rotation=90)
    "Outdoor air damper"
    annotation (
    Placement(transformation(extent={{-154,-90},{-130,-70}})));

  Buildings.Templates.Components.Dampers.PressureIndependent damRet(
    redeclare final package Medium = MediumAir,
    final dat=dat.damRet,
    final text_rotation=90)
    "Return damper"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,0})));

  // Currently only the configuration without heat recovery is supported.

  Buildings.Templates.Components.Sensors.Temperature TOut(
    redeclare final package Medium = MediumAir,
    final have_sen=true,
    final m_flow_nominal=dat.damOut.m_flow_nominal)
    "Outdoor air temperature sensor"
    annotation (Placement(transformation(extent={{-64,-90},{-44,-70}})));
  Buildings.Templates.Components.Sensors.VolumeFlowRate VOut_flow(
    redeclare final package Medium = MediumAir,
    final have_sen=true,
    final m_flow_nominal=dat.damOut.m_flow_nominal,
    final typ=Buildings.Templates.Components.Types.SensorVolumeFlowRate.AFMS)
    "Outdoor air volume flow rate sensor"
    annotation (Placement(transformation(extent={{-32,-90},{-12,-70}})));
  Buildings.Templates.Components.Sensors.DifferentialPressure pAirRet_rel(
      redeclare final package Medium = MediumAir, final have_sen=true)
    "Return fan discharge static pressure sensor"
    annotation (Placement(transformation(extent={{52,110},{72,130}})));
  Buildings.Fluid.FixedResistances.Junction splRet(
    redeclare final package Medium = MediumAir,
    final m_flow_nominal={1,-1,-1}*dat.damRel.m_flow_nominal,
    final dp_nominal=fill(0, 3),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState) "Splitter"
    annotation (Placement(transformation(extent={{10,70},{-10,90}})));
  Buildings.Templates.Components.Dampers.PressureIndependent damRel(
    redeclare final package Medium = MediumAir,
    final dat=dat.damRel,
    final text_flip=true)
    "Relief damper"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-110,80})));
  Buildings.Templates.Components.Sensors.SpecificEnthalpy  hAirOut(
    redeclare final package Medium = MediumAir,
    final have_sen=typCtlEco == Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.FixedEnthalpyWithFixedDryBulb
         or typCtlEco == Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.DifferentialEnthalpyWithFixedDryBulb,
    final m_flow_nominal=dat.damOut.m_flow_nominal) "Outdoor air enthalpy sensor"
    annotation (Placement(transformation(extent={{-100,-90},{-80,-70}})));

equation
  /* Control point connection - start */
  connect(damRet.bus, bus.damRet);
  connect(damOut.bus, bus.damOut);
  connect(damRel.bus, bus.damRel);
  connect(TOut.y, bus.TOut);
  connect(hAirOut.y, bus.hAirOut);
  connect(VOut_flow.y, bus.VOut_flow);
  connect(pAirRet_rel.y, bus.pAirRet_rel);
  /* Control point connection - end */
  connect(port_Out,damOut. port_a)
    annotation (Line(points={{-180,-80},{-154,-80}},color={0,127,255}));
  connect(damRet.port_b, port_Sup)
    annotation (Line(points={{0,-10},{0,-80},{180,-80}}, color={0,127,255}));
  connect(TOut.port_b,VOut_flow. port_a)
    annotation (Line(points={{-44,-80},{-32,-80}},
                                             color={0,127,255}));
  connect(VOut_flow.port_b, damRet.port_b) annotation (Line(points={{-12,-80},{0,
          -80},{0,-10},{-1.77636e-15,-10}}, color={0,127,255}));
  connect(pAirRet_rel.port_a,splRet. port_1) annotation (Line(points={{52,120},{
          22,120},{22,80},{10,80}},
                          color={0,127,255}));
  connect(damRel.port_a,splRet. port_2)
    annotation (Line(points={{-100,80},{-10,80}},
                                                color={0,127,255}));
  connect(pAirRet_rel.port_b, port_bPre)
    annotation (Line(points={{72,120},{80,120},{80,140}}, color={0,127,255}));
  connect(splRet.port_1, port_Ret)
    annotation (Line(points={{10,80},{180,80}}, color={0,127,255}));
  connect(damRel.port_b, port_Rel)
    annotation (Line(points={{-120,80},{-180,80}}, color={0,127,255}));
  connect(splRet.port_3, damRet.port_a)
    annotation (Line(points={{0,70},{0,10}}, color={0,127,255}));

  connect(hAirOut.port_b, TOut.port_a)
    annotation (Line(points={{-80,-80},{-64,-80}}, color={0,127,255}));
  connect(hAirOut.port_a, damOut.port_b)
    annotation (Line(points={{-100,-80},{-130,-80}}, color={0,127,255}));
  annotation (Documentation(info="<html>
<p>This model represents an OA mixer with pressure dependent dampers. </p>
</html>"));
end OutdoorAirMixer;
