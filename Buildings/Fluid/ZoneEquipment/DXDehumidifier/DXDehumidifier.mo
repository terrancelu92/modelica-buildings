within Buildings.Fluid.ZoneEquipment.DXDehumidifier;
model DXDehumidifier "DX dehumidifier"
  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final
      Buildings.Fluid.MixingVolumes.MixingVolumeMoistAir vol(final
        prescribedHeatFlowRate=false));
  parameter Modelica.Units.SI.VolumeFlowRate V_flow_nominal(min=0)
    "Rated water removal rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Real eneFac_nominal(min=0) "L/kwh, Rated energy factor"
    annotation (Dialog(group="Nominal condition"));
  parameter Buildings.Fluid.ZoneEquipment.DXDehumidifier.Data.Generic per
    "Performance data"
    annotation (choicesAllMatching = true,
                Placement(transformation(extent={{-80,84},{-60,104}})));

  Real watRemMod(each min=0, each nominal=1, each start=1)
    "Water removal modifier factor as a function of temperature and RH";

  Real eneFacMod(each min=0, each nominal=1, each start=1)
    "Energy factor modifier factor as a function of temperature and RH";


  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo
    annotation (Placement(transformation(extent={{-50,50},{-30,70}})));
  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heaFloSen
    annotation (Placement(transformation(extent={{-20,50},{0,70}})));


  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTem
    "Temperature sensor"
    annotation (Placement(transformation(extent={{36,70},{56,90}})));
  Modelica.Blocks.Interfaces.RealOutput T(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));
  Modelica.Blocks.Interfaces.RealOutput X_w(final unit="kg/kg")
    "Species composition of medium"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}}),
        iconTransformation(extent={{100,-70},{120,-50}})));

  Modelica.Blocks.Sources.RealExpression mWat_flow(y=V_flow_nominal*rhoWat*
        watRemMod)
    annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Modelica.Blocks.Sources.RealExpression QHea(y=Pdeh.y + mWat_flow.y*h_fg)
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  Modelica.Blocks.Interfaces.RealOutput Q_flow(unit="W") "Air heating rate"
    annotation (Placement(transformation(extent={{100,26},{120,46}})));
  Modelica.Blocks.Interfaces.RealOutput P(unit="W") "Power consumption rate"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
  Modelica.Blocks.Sources.RealExpression Pdeh(y=V_flow_nominal*watRemMod/
        eneFac_nominal/eneFacMod*1000*1000*3600)
    annotation (Placement(transformation(extent={{-80,-70},{-60,-50}})));
  Sensors.TemperatureTwoPort TIn(redeclare package Medium = Medium,
      m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
  Modelica.Blocks.Interfaces.RealInput phi
    annotation (Placement(transformation(extent={{-120,30},{-100,50}})));
protected
  constant Modelica.Units.SI.SpecificEnthalpy h_fg=
       Buildings.Utilities.Psychrometrics.Constants.h_fg "Latent heat of water vapor";
  constant Modelica.Units.SI.Density rhoWat=1000 "Water density";


equation
    //-------------------------Part-load performance modifiers----------------------------//
    // Compute the water removal and energy factor modifier fractions, using a biquadratic curve.
    // Since the regression for capacity can have negative values
    // (for unreasonable inputs), we constrain its return value to be
    // non-negative.
    watRemMod =Buildings.Utilities.Math.Functions.smoothMax(
        x1=Buildings.Utilities.Math.Functions.biquadratic(
          a=per.watRem,
          x1=Modelica.Units.Conversions.to_degC(TIn.T),
          x2=phi),
        x2=0.001,
        deltaX=0.0001);
    eneFacMod =Buildings.Utilities.Math.Functions.smoothMax(
        x1=Buildings.Utilities.Math.Functions.biquadratic(
          a=per.eneFac,
          x1=Modelica.Units.Conversions.to_degC(TIn.T),
          x2=phi),
        x2=0.001,
        deltaX=0.0001);

  connect(preHeaFlo.port, heaFloSen.port_a)
    annotation (Line(points={{-30,60},{-20,60}}, color={191,0,0}));
  connect(vol.X_w, X_w) annotation (Line(points={{13,-6},{40,-6},{40,-60},{110,
          -60}}, color={0,0,127}));
  connect(heaFloSen.port_b, vol.heatPort) annotation (Line(points={{0,60},{0,34},
          {-16,34},{-16,-10},{-9,-10}},            color={191,0,0}));
  connect(senTem.T, T)
    annotation (Line(points={{57,80},{110,80}}, color={0,0,127}));
  connect(vol.heatPort, senTem.port) annotation (Line(points={{-9,-10},{-12,-10},
          {-12,32},{20,32},{20,80},{36,80}}, color={191,0,0}));
  connect(mWat_flow.y, vol.mWat_flow) annotation (Line(points={{-59,-40},{-26,-40},
          {-26,-18},{-11,-18}}, color={0,0,127}));
  connect(QHea.y, preHeaFlo.Q_flow)
    annotation (Line(points={{-59,60},{-50,60}}, color={0,0,127}));
  connect(TIn.port_a, port_a)
    annotation (Line(points={{-90,0},{-100,0}}, color={0,127,255}));
  connect(TIn.port_b, preDro.port_a)
    annotation (Line(points={{-70,0},{-60,0}}, color={0,127,255}));
  connect(Pdeh.y, P) annotation (Line(points={{-59,-60},{20,-60},{20,-20},{110,-20}},
        color={0,0,127}));
  connect(Q_flow, QHea.y) annotation (Line(points={{110,36},{-56,36},{-56,60},{-59,
          60}}, color={0,0,127}));
  annotation (
defaultComponentName="evaCon",
Documentation(info="<html>
</html>",
revisions="<html>
<ul>
<li>
March 7, 2022, by Michael Wetter:<br/>
Removed <code>massDynamics</code>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1542\">#1542</a>.
</li>
<li>
May 27, 2017, by Filip Jorissen:<br/>
Regularised heat transfer around zero flow.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/769\">#769</a>.
</li>
<li>
April 12, 2017, by Michael Wetter:<br/>
Corrected invalid syntax for computing the specific heat capacity.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/707\">#707</a>.
</li>
<li>
October 11, 2016, by Massimo Cimmino:<br/>
First implementation.
</li>
</ul>
</html>"));
end DXDehumidifier;
