within Buildings.Fluid.ZoneEquipment.DXDehumidifier;
model DXDehumidifier "DX dehumidifier"
  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(
  redeclare final Buildings.Fluid.MixingVolumes.MixingVolumeMoistAir vol(final
        prescribedHeatFlowRate=false),
  energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial);
  parameter Modelica.Units.SI.VolumeFlowRate V_flow_nominal(min=0) = 5.805556e-7
    "Rated water removal rate, in m3/s"
    annotation (Dialog(group="Nominal condition"));
  parameter Real eneFac_nominal(min=0) = 3.412 "Rated energy factor, in L/kwh"
    annotation (Dialog(group="Nominal condition"));
  parameter Buildings.Fluid.ZoneEquipment.DXDehumidifier.Data.Generic per
    "Performance data"
    annotation (choicesAllMatching = true,
                Placement(transformation(extent={{-80,84},{-60,104}})));

  Modelica.Blocks.Interfaces.BooleanInput uEna
    "Enable signal" annotation (Placement(transformation(extent={{-122,-50},{-102,
            -30}}),iconTransformation(extent={{-122,-50},{-102,-30}})));

  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo
    annotation (Placement(transformation(extent={{-50,50},{-30,70}})));
  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heaFloSen
    annotation (Placement(transformation(extent={{-20,50},{0,70}})));


  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTem
    "Temperature sensor"
    annotation (Placement(transformation(extent={{36,70},{56,90}})));
  Modelica.Blocks.Interfaces.RealOutput T(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{100,40},{120,60}}),
        iconTransformation(extent={{100,40},{120,60}})));
  Modelica.Blocks.Interfaces.RealOutput X_w(final unit="kg/kg")
    "Species composition of medium"
    annotation (Placement(transformation(extent={{100,-60},{120,-40}}),
        iconTransformation(extent={{100,-60},{120,-40}})));

  Modelica.Blocks.Sources.RealExpression mWat_flow(y=if uEna == true then -
        V_flow_nominal*rhoWat*watRemMod else 0)
    annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Modelica.Blocks.Sources.RealExpression QHea(y=if uEna == true then Pdeh.y + (
        -mWat_flow.y)*h_fg else 0)
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  Modelica.Blocks.Interfaces.RealOutput Q_flow(unit="W") "Air heating rate"
    annotation (Placement(transformation(extent={{100,10},{120,30}}),
        iconTransformation(extent={{100,10},{120,30}})));
  Modelica.Blocks.Interfaces.RealOutput P(unit="W") "Power consumption rate"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}}),
        iconTransformation(extent={{100,-30},{120,-10}})));
  Modelica.Blocks.Sources.RealExpression Pdeh(y=if uEna == true then
        V_flow_nominal*watRemMod/eneFac_nominal/eneFacMod*1000*1000*3600 else 0)
    annotation (Placement(transformation(extent={{-80,-70},{-60,-50}})));

  Sensors.Temperature senTIn(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-100,22},{-80,42}})));
  Sensors.RelativeHumidity senRelHum(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-80,22},{-60,42}})));
protected
  constant Modelica.Units.SI.SpecificEnthalpy h_fg= 2501014.5
       "2501014.5 Buildings.Utilities.Psychrometrics.Constants.h_fg Latent heat of water vapor";
  constant Modelica.Units.SI.Density rhoWat=1000 "Water density";

  Real watRemMod(each min=0, each nominal=1, each start=1)
    "Water removal modifier factor as a function of temperature and RH";

  Real eneFacMod(each min=0, each nominal=1, each start=1)
    "Energy factor modifier factor as a function of temperature and RH";

equation
    //-------------------------Part-load performance modifiers----------------------------//
    // Compute the water removal and energy factor modifier fractions, using a biquadratic curve.
    // Since the regression for capacity can have negative values
    // (for unreasonable inputs), we constrain its return value to be
    // non-negative.
    watRemMod =Buildings.Utilities.Math.Functions.smoothMax(
        x1=Buildings.Utilities.Math.Functions.biquadratic(
          a=per.watRem,
          x1=Modelica.Units.Conversions.to_degC(senTIn.T),
          x2=senRelHum.phi*100),
        x2=0.001,
        deltaX=0.0001);
    eneFacMod =Buildings.Utilities.Math.Functions.smoothMax(
        x1=Buildings.Utilities.Math.Functions.biquadratic(
          a=per.eneFac,
          x1=Modelica.Units.Conversions.to_degC(senTIn.T),
          x2=senRelHum.phi*100),
        x2=0.001,
        deltaX=0.0001);

  connect(preHeaFlo.port, heaFloSen.port_a)
    annotation (Line(points={{-30,60},{-20,60}}, color={191,0,0}));
  connect(vol.X_w, X_w) annotation (Line(points={{13,-6},{40,-6},{40,-50},{110,-50}},
                 color={0,0,127}));
  connect(heaFloSen.port_b, vol.heatPort) annotation (Line(points={{0,60},{0,34},
          {-16,34},{-16,-10},{-9,-10}},            color={191,0,0}));
  connect(senTem.T, T)
    annotation (Line(points={{57,80},{84,80},{84,50},{110,50}},
                                                color={0,0,127}));
  connect(vol.heatPort, senTem.port) annotation (Line(points={{-9,-10},{-12,-10},
          {-12,32},{20,32},{20,80},{36,80}}, color={191,0,0}));
  connect(QHea.y, preHeaFlo.Q_flow)
    annotation (Line(points={{-59,60},{-50,60}}, color={0,0,127}));
  connect(Pdeh.y, P) annotation (Line(points={{-59,-60},{20,-60},{20,-20},{110,-20}},
        color={0,0,127}));
  connect(Q_flow, QHea.y) annotation (Line(points={{110,20},{-54,20},{-54,60},{
          -59,60}},
                color={0,0,127}));
  connect(mWat_flow.y, vol.mWat_flow) annotation (Line(points={{-59,-40},{-36,
          -40},{-36,-18},{-11,-18}}, color={0,0,127}));
  connect(senTIn.port, port_a)
    annotation (Line(points={{-90,22},{-90,0},{-100,0}}, color={0,127,255}));
  connect(senRelHum.port, port_a)
    annotation (Line(points={{-70,22},{-70,0},{-100,0}}, color={0,127,255}));
  annotation (
defaultComponentName="dxDeh",
Documentation(info="<html>
<p>This is a zone air DX dehumidifier model. The model assumes that this equipment removes the moisture from the air stream and simultaneously heats the air. </p>
<p>Two performance curves <span style=\"font-family: Courier New;\">watRemMod</span> and <span style=\"font-family: Courier New;\">eneFacMod</span> are specified to characterize the change in water removal and energy consumption at part-load conditions.</p>
<p>The amount of exchanged moisture <span style=\"font-family: Courier New;\">mWat_flow</span> is equal to</p>
<p align=\"center\"><i>ṁ<sub>wat_flow</sub> = watRemMod &rho; V̇<sub>flow_nominal</sub> ,</i></p>
<p><br>The amount of heat added to the air stream <span style=\"font-family: Courier New;\">QHea</span> is equal to </p>
<p align=\"center\"><i>Q̇<sub>hea</sub> = ṁ<sub>wat_flow</sub> h<sub>fg</sub> + P<sub>deh</sub> ,</p><p align=\"center\">P<sub>deh</sub> = V̇<sub>flow_nominal</sub> watRemMod / (eneFac<sub>nominal</sub> eneFacMod), </i></p>
<p><br>where <span style=\"font-family: Courier New;\">V_flow_nominal</span> is the rated water removal flow rate and <span style=\"font-family: Courier New;\">eneFac_nominal</span> is the rated energy factor. h<sub>fg</sub> is the enthalpy of vaporization of air. </p>
<p><br><h4>Performance Curve Modifiers</h4></p>
<p>The water removal modifier curve <span style=\"font-family: Courier New;\">watRemMod</span> is a biquadratic curve with two independent variables: dry-bulb temperature and relative humidity of the air entering the dehumidifier.</p>
<p align=\"center\"><i>watRemMod(T<sub>in</sub>, phi<sub>in</sub>) = a<sub>1</sub> + a<sub>2</sub> T<sub>in</sub> + a<sub>3</sub> T<sub>in</sub> <sup>2</sup> + a<sub>4</sub> phi<sub>in</sub> + a<sub>5</sub> phi<sub>in</sub> <sup>2</sup> + a<sub>6</sub> T<sub>in</sub> phi<sub>in</sub>. </i></p>
<p>The energy factor modifier curve <span style=\"font-family: Courier New;\">eneFacMod</span> is a biquadratic curve with two independent variables: dry-bulb temperature and relative humidity of the air entering the dehumidifier. </p>
<p align=\"center\"><i>eneFacMod(T<sub>in</sub>, phi<sub>in</sub>) = b<sub>1</sub> + b<sub>2</sub> T<sub>in</sub> + b<sub>3</sub> T<sub>in</sub> <sup>2</sup> + b<sub>4</sub> phi<sub>in</sub> + b<sub>5</sub> phi<sub>in</sub> <sup>2</sup> + b<sub>6</sub> T<sub>in</sub> phi<sub>in</sub>. </i></p>
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
</html>"),
    Icon(coordinateSystem(extent={{-100,-80},{100,80}})),
    Diagram(coordinateSystem(extent={{-100,-80},{100,100}})));
end DXDehumidifier;
