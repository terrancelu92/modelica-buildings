within Buildings.Templates.Components.OutdoorAirMixer.Examples;
model VAVMZReliefDamperNoFan
  "Validation model for multiple-zone VAV - Base model with open loop controls"
  extends Modelica.Icons.Example;
  replaceable package MediumAir=Buildings.Media.Air
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Air medium";
  replaceable package MediumChiWat=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Cooling medium (such as CHW)";
  replaceable package MediumHeaWat=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Heating medium (such as HHW)";

  inner parameter
    Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses.AllSystems
    datAll(
    sysUni=Buildings.Templates.Types.Units.SI,
    redeclare replaceable model VAV =
        Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses.VAVMZReliefDamperNoFan,
    stdEne=Buildings.Controls.OBC.ASHRAE.G36.Types.EnergyStandard.ASHRAE90_1,
    stdVen=Buildings.Controls.OBC.ASHRAE.G36.Types.VentilationStandard.ASHRAE62_1,
    ashCliZon=Buildings.Controls.OBC.ASHRAE.G36.Types.ASHRAEClimateZone.Zone_3B)
    "Design and operating parameters"
    annotation (Placement(transformation(extent={{92,92},{112,112}})));

  inner Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses.VAVMZReliefDamperNoFan
    VAV_1  "Air handling unit"
    annotation (Placement(transformation(extent={{-20,-50},{20,-10}})));
  Buildings.Fluid.Sources.Boundary_pT bouOut(
    redeclare final package Medium =MediumAir,
    nPorts=2)
    "Boundary conditions for outdoor environment"
    annotation (Placement(transformation(extent={{-100,-40},{-80,-20}})));
  Buildings.Fluid.Sources.Boundary_pT bouBui(
    redeclare final package Medium =MediumAir,
    nPorts=3)
    "Boundary conditions for indoor environment"
    annotation (Placement(transformation(extent={{90,-40},{70,-20}})));
  Fluid.FixedResistances.PressureDrop res(
    redeclare final package Medium=MediumAir,
    m_flow_nominal=1, dp_nominal=100)
    annotation (Placement(transformation(extent={{-50,-50},{-30,-30}})));
  Fluid.FixedResistances.PressureDrop res1(
    redeclare final package Medium = MediumAir,
    m_flow_nominal=1,
    dp_nominal=100)
    annotation (Placement(transformation(extent={{30,-50},{50,-30}})));
  Fluid.Sensors.Pressure pBui(redeclare final package Medium = MediumAir)
    "Building absolute pressure in representative space"
    annotation (Placement(transformation(extent={{80,0},{60,20}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
    Modelica.Utilities.Files.loadResource(
    "modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"))
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Fluid.FixedResistances.PressureDrop res2(
    redeclare final package Medium = MediumAir,
    m_flow_nominal=1,
    dp_nominal=100)
    annotation (Placement(transformation(extent={{-30,-30},{-50,-10}})));
  Fluid.FixedResistances.PressureDrop res3(
    redeclare final package Medium = MediumAir,
    m_flow_nominal=1,
    dp_nominal=100)
    annotation (Placement(transformation(extent={{50,-30},{30,-10}})));
  Fluid.Sources.Boundary_pT bouHeaWat(
    redeclare final package Medium = MediumHeaWat,
    nPorts=2) if VAV_1.have_souHeaWat
    "Boundary conditions for HHW distribution system"
    annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
  Fluid.Sources.Boundary_pT bouChiWat(
    redeclare final package Medium = MediumChiWat,
    nPorts=2) if VAV_1.have_souChiWat
    "Boundary conditions for CHW distribution system"
    annotation (Placement(transformation(extent={{-100,-110},{-80,-90}})));
  AirHandlersFans.Validation.UserProject.ZoneEquipment.VAVBoxControlPoints sigVAVBox[VAV_1.nZon](
     each final stdVen=datAll.stdVen) if VAV_1.ctl.typ == Buildings.Templates.AirHandlersFans.Types.Controller.G36VAVMultiZone
    "Control signals from VAV box"
    annotation (Placement(transformation(extent={{-100,20},{-80,40}})));
  ZoneEquipment.Validation.UserProject.BASControlPoints sigBAS(
    final nZon=VAV_1.nZon)
    "BAS control points"
    annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
  ZoneEquipment.Validation.UserProject.ZoneControlPoints sigZon[VAV_1.nZon]
    "Zone control points"
    annotation (Placement(transformation(extent={{-100,50},{-80,70}})));
protected
  AirHandlersFans.Interfaces.Bus busAHU "Gateway bus" annotation (Placement(
        transformation(extent={{-40,-10},{0,30}}), iconTransformation(extent={{-258,
            -26},{-238,-6}})));

equation
  connect(bouHeaWat.ports[1], VAV_1.port_aHeaWat)
    annotation (Line(points={{-80,-68},{-5,-68},{-5,-50}}, color={0,127,255}));
  connect(bouChiWat.ports[2], VAV_1.port_bChiWat)
    annotation (Line(points={{-80,-102},{5,-102},{5,-50}},color={0,127,255}));
  connect(VAV_1.port_bHeaWat, bouHeaWat.ports[2]) annotation (Line(points={{-13,-50},
          {-13,-68},{-80,-68},{-80,-72}},      color={0,127,255}));
  connect(VAV_1.port_aChiWat, bouChiWat.ports[1]) annotation (Line(points={{13,-50},
          {13,-102},{-80,-102},{-80,-98}},
                                      color={0,127,255}));
  connect(bouOut.ports[1], res.port_a) annotation (Line(points={{-80,-28},{-60,-28},
          {-60,-40},{-50,-40}}, color={0,127,255}));
  connect(res.port_b, VAV_1.port_Out)
    annotation (Line(points={{-30,-40},{-20,-40}}, color={0,127,255}));
  connect(VAV_1.port_Sup, res1.port_a)
    annotation (Line(points={{20,-40},{30,-40}}, color={0,127,255}));
  connect(res1.port_b, bouBui.ports[1]) annotation (Line(points={{50,-40},{60,
          -40},{60,-27.3333},{70,-27.3333}},
                                        color={0,127,255}));
  connect(bouBui.ports[2], pBui.port)
    annotation (Line(points={{70,-30},{70,0}},           color={0,127,255}));
  connect(weaDat.weaBus, VAV_1.busWea) annotation (Line(
      points={{-80,0},{0,0},{0,-10}},
      color={255,204,51},
      thickness=0.5));
  connect(busAHU, VAV_1.bus) annotation (Line(
      points={{-20,10},{-20,-14},{-19.9,-14}},
      color={255,204,51},
      thickness=0.5));
  connect(VAV_1.port_Rel, res2.port_a)
    annotation (Line(points={{-20,-20},{-30,-20}},
                                                 color={0,127,255}));
  connect(res2.port_b, bouOut.ports[2]) annotation (Line(points={{-50,-20},{-60,
          -20},{-60,-32},{-80,-32}},
                            color={0,127,255}));
  connect(VAV_1.port_Ret, res3.port_b)
    annotation (Line(points={{20,-20},{30,-20}},
                                               color={0,127,255}));
  connect(res3.port_a, bouBui.ports[3]) annotation (Line(points={{50,-20},{60,
          -20},{60,-32.6667},{70,-32.6667}},
                                      color={0,127,255}));
  connect(pBui.p, busAHU.pBui) annotation (Line(points={{59,10},{-20,10}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigVAVBox.bus, VAV_1.busTer) annotation (Line(
      points={{-80,30},{19.8,30},{19.8,-14}},
      color={255,204,51},
      thickness=0.5));

  connect(sigBAS.busTer, VAV_1.busTer) annotation (Line(
      points={{-80,90},{19.8,90},{19.8,-14}},
      color={255,204,51},
      thickness=0.5));
  connect(sigZon.bus, VAV_1.busTer) annotation (Line(
      points={{-80,60},{19.8,60},{19.8,-14}},
      color={255,204,51},
      thickness=0.5));
  annotation (
  experiment(
      StartTime=15552000,
      StopTime=15638400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),        Documentation(info="<html>
<p>
This is a validation model for the configuration represented by
<a href=\"modelica://Buildings.Templates.Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses.VAVMZBase\">
Buildings.Templates.Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses.VAVMZBase</a>
</p>
</html>"),
    Diagram(coordinateSystem(extent={{-120,-120},{120,120}})));
end VAVMZReliefDamperNoFan;
