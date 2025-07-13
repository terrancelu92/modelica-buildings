within Buildings.Applications.DataCenters.ChillerCooled.Examples;
model IntegratedPrimaryLoadSideEconomizerCustomized
  "Example that demonstrates a chiller plant with integrated primary load side economizer"
  extends Modelica.Icons.Example;
  extends
    Buildings.Applications.DataCenters.ChillerCooled.Examples.BaseClasses.PostProcess(
    freCooSig(
      y=if cooModCon.y == Integer(Buildings.Applications.DataCenters.Types.CoolingModes.FreeCooling)
      then 1 else 0),
    parMecCooSig(
      y=if cooModCon.y == Integer(Buildings.Applications.DataCenters.Types.CoolingModes.PartialMechanical)
      then 1 else 0),
    fulMecCooSig(
      y=if cooModCon.y == Integer(Buildings.Applications.DataCenters.Types.CoolingModes.FullMechanical)
      then 1 else 0),
    PHVAC(y=cooTow[1].PFan + cooTow[2].PFan + pumCW[1].P + pumCW[2].P + sum(
          chiWSE.powChi + chiWSE.powPum) + sum(ahu.PFan) + sum(ahu.PHea)),
    PIT(y=sum(rac.QSou.Q_flow)));
  extends
    Buildings.Applications.DataCenters.ChillerCooled.Examples.BaseClasses.PartialDataCenterAirSide(
    redeclare Buildings.Applications.DataCenters.ChillerCooled.Equipment.IntegratedPrimaryLoadSide chiWSE(
      addPowerToMedium=false,
      perPum=perPumPri),
    weaData(filNam=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")),
    rac(QRoo_flow={125000*(0.7 + 0.3*(sin(2*3.14159*(time/86400 - 0.25)) + 1)/2
           + 0.1*sin(2*3.14159*time/3600)),125000*(0.72 + 0.28*(sin(2*3.14159*(
          time/86400 - 0.27)) + 1)/2 + 0.08*sin(2*3.14159*time/3300)),125000*(
          0.75 + 0.25*(sin(2*3.14159*(time/86400 - 0.23)) + 1)/2 + 0.12*sin(2*
          3.14159*time/3900)),125000*(0.68 + 0.32*(sin(2*3.14159*(time/86400 -
          0.29)) + 1)/2 + 0.09*sin(2*3.14159*time/2700))}),
    ahuValSig(
      Ti=300,
      initType=Modelica.Blocks.Types.Init.InitialOutput,
      y_start=1),
    ahuFanSpeCon(
      Ti=3600,
      yMin=0.01,
      initType=Modelica.Blocks.Types.Init.InitialOutput,
      y_start=1),
    ahu(yFan_start=1),
    varSpeCon(tWai=0),
    TAirSupSet(y={TSupAirRan[1].y,TSupAirRan[2].y,TSupAirRan[3].y,TSupAirRan[4].y}),
    TAirRetSet(y={TRacTemRan[1].y,TRacTemRan[2].y,TRacTemRan[3].y,TRacTemRan[4].y}),
    phiAirRetSet(y={phiRan[1].y,phiRan[2].y,phiRan[3].y,phiRan[4].y}),
    hea(Q_flow_nominal=-150000));




  parameter Buildings.Fluid.Movers.Data.Generic[numChi] perPumPri(
    each pressure=Buildings.Fluid.Movers.BaseClasses.Characteristics.flowParameters(
          V_flow=m2_flow_chi_nominal/1000*{0.2,0.6,1.0,1.2},
          dp=(dp2_chi_nominal+dp2_wse_nominal+18000)*{1.5,1.3,1.0,0.6}))
    "Performance data for primary pumps";

  Buildings.Applications.DataCenters.ChillerCooled.Controls.CoolingMode
    cooModCon(
    tWai=tWai,
    deaBan1=1.1,
    deaBan2=0.5,
    deaBan3=1.1,
    deaBan4=0.5)
    "Cooling mode controller"
    annotation (Placement(transformation(extent={{-214,100},{-194,120}})));
  Modelica.Blocks.Sources.RealExpression towTApp(y=cooTow[1].TApp_nominal)
    "Cooling tower approach temperature"
    annotation (Placement(transformation(extent={{-320,100},{-300,120}})));
  Modelica.Blocks.Sources.RealExpression yVal5(
    y=if cooModCon.y == Integer(
    Buildings.Applications.DataCenters.Types.CoolingModes.FullMechanical)
    then 1 else 0)
    "On/off signal for valve 5"
    annotation (Placement(transformation(extent={{-160,30},{-140,50}})));
  Modelica.Blocks.Sources.RealExpression yVal6(
    y=if cooModCon.y == Integer(
    Buildings.Applications.DataCenters.Types.CoolingModes.FreeCooling)
    then 1 else 0)
    "On/off signal for valve 6"
    annotation (Placement(transformation(extent={{-160,14},{-140,34}})));

  Modelica.Blocks.Sources.RealExpression cooLoaChi(
    y=-chiWSE.port_a2.m_flow*4180*(chiWSE.TCHWSupWSE - TCHWSupSet.y))
    "Cooling load in chillers"
    annotation (Placement(transformation(extent={{-320,130},{-300,150}})));
  BaseClasses.SignalStep TSupAirRan[numChiDor](
    yMin=12 + 273.15,
    yMax=19 + 273.15,
    sampleTime={1800,3600,2400,2700},
    randomSeed={1,188,366,799},
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{80,-160},{100,-140}})));
  BaseClasses.SignalStep TRacTemRan[numChiDor](
    yMin=23 + 273.15,
    yMax=25 + 273.15,
    sampleTime={3600,2700,2400,2100},
    randomSeed={188,2000,3660,799},
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{80,-200},{100,-180}})));
  BaseClasses.SignalStep phiRan[numChiDor](
    yMin=0.4,
    yMax=0.6,
    sampleTime={3600,7200,4200,5400},
    randomSeed={1288,5000,36660,7779},
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{80,-240},{100,-220}})));
equation

  connect(pumSpeSig.y, chiWSE.yPum)
    annotation (Line(
      points={{-99,-10},{-60,-10},{-60,25.6},{-1.6,25.6}},
      color={0,0,127}));
  connect(chiWSE.TCHWSupWSE, cooModCon.TCHWSupWSE)
    annotation (Line(
      points={{21,34},{148,34},{148,200},{-226,200},{-226,106},{-216,106}},
      color={0,0,127}));
  connect(cooLoaChi.y, chiStaCon.QTot)
    annotation (Line(
      points={{-299,140},{-172,140}},
      color={0,0,127}));
   for i in 1:numChi loop
    connect(pumCW[i].port_a, TCWSup.port_b)
      annotation (Line(
        points={{-50,110},{-50,140},{-42,140}},
        color={0,127,255},
        thickness=0.5));
   end for;
  connect(TCHWSupSet.y, cooModCon.TCHWSupSet)
    annotation (Line(
      points={{-239,160},{-222,160},{-222,118},{-216,118}},
      color={0,0,127}));
  connect(towTApp.y, cooModCon.TApp)
    annotation (Line(
      points={{-299,110},{-216,110}},
      color={0,0,127}));
  connect(TCHWRet.port_b, chiWSE.port_a2)
    annotation (Line(
      points={{80,0},{40,0},{40,24},{20,24}},
      color={0,127,255},
      thickness=0.5));
  connect(cooModCon.TCHWRetWSE, TCHWRet.T)
    annotation (Line(
      points={{-216,102},{-228,102},{-228,206},{152,206},{152,20},{90,20},{90,
          11}},
    color={0,0,127}));

  connect(cooModCon.y, chiStaCon.cooMod)
    annotation (Line(
      points={{-193,110},{-190,110},{-190,146},{-172,146}},
      color={255,127,0}));
  connect(cooModCon.y,intToBoo.u)
    annotation (Line(
      points={{-193,110},{-172,110}},
      color={255,127,0}));
  connect(TCHWSup.T, chiStaCon.TCHWSup)
    annotation (Line(
      points={{-26,11},{-26,18},{-182,18},{-182,134},{-172,134}},
      color={0,0,127}));
  connect(cooModCon.y, sigCha.u)
    annotation (Line(
      points={{-193,110},{-190,110},{-190,212},{156,212},{156,160},{178,160}},
      color={255,127,0}));
  connect(yVal5.y, chiWSE.yVal5) annotation (Line(points={{-139,40},{-84,40},{
          -84,33},{-1.6,33}}, color={0,0,127}));
  connect(yVal6.y, chiWSE.yVal6) annotation (Line(points={{-139,24},{-84,24},{
          -84,29.8},{-1.6,29.8}}, color={0,0,127}));
  connect(cooModCon.y, cooTowSpeCon.cooMod) annotation (Line(points={{-193,110},
          {-190,110},{-190,182.444},{-172,182.444}}, color={255,127,0}));
  connect(cooModCon.y, CWPumCon.cooMod) annotation (Line(points={{-193,110},{-190,
          110},{-190,76},{-174,76}},      color={255,127,0}));
  connect(weaBus.TWetBul, cooModCon.TWetBul) annotation (Line(
      points={{-327.95,-19.95},{-340,-19.95},{-340,200},{-224,200},{-224,114},{-216,
          114}},
      color={255,204,51},
      thickness=0.5));

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false,
    extent={{-360,-280},{320,260}})),
  __Dymola_Commands(file=
  "modelica://Buildings/Resources/Scripts/Dymola/Applications/DataCenters/ChillerCooled/Examples/IntegratedPrimaryLoadSideEconomizer.mos"
  "Simulate and plot"),
   Documentation(info="<html>
<p>// Base load: 125,000 W (500,000/4) each </p>
<p>// Time is in seconds </p>
<p>// CPU 1: Business Hours Pattern (Primary server) </p>
<p>// Peak during business hours (9 AM - 6 PM), minimum at night (2-6 AM) </p>
<p>y = 125000 * (0.7 + 0.3 * (sin(2*3.14159*(time/86400 - 0.25)) + 1)/2 + 0.1 * sin(2*3.14159*time/3600)) &nbsp; </p>
<p>// CPU 2: Business Hours Pattern (Secondary server - slightly offset) </p>
<p>// Similar to CPU 1 but with 30-minute phase shift and different noise </p>
<p>y = 125000 * (0.72 + 0.28 * (sin(2*3.14159*(time/86400 - 0.27)) + 1)/2 + 0.08 * sin(2*3.14159*time/3300)) </p>
<p>// CPU 3: Business Hours Pattern (Tertiary server - different amplitude) </p>
<p>// Similar pattern but with reduced peak variation and different frequency </p>
<p>y = 125000 * (0.75 + 0.25 * (sin(2*3.14159*(time/86400 - 0.23)) + 1)/2 + 0.12 * sin(2*3.14159*time/3900)) </p>
<p>// CPU 4: Business Hours Pattern (Quaternary server - load balancer effect) </p>
<p>// Similar but with smoother transitions and slight time offset </p>
<p>y = 125000 * (0.68 + 0.32 * (sin(2*3.14159*(time/86400 - 0.29)) + 1)/2 + 0.09 * sin(2*3.14159*time/2700)) </p>
<p>// Profile Characteristics: </p>
<p>// CPU 1: 87,500 - 162,500 W (Primary server) </p>
<p>// CPU 2: 90,000 - 160,000 W (Secondary, 30-min offset) </p>
<p>// CPU 3: 93,750 - 156,250 W (Tertiary, smoother variation) </p>
<p>// CPU 4: 85,000 - 165,000 W (Quaternary, load balancer effect) </p>
<p>// Key Differences Between CPUs: </p>
<p>// - Phase shifts: -0.25, -0.27, -0.23, -0.29 (different peak times) </p>
<p>// - Base levels: 0.7, 0.72, 0.75, 0.68 (slightly different minimum loads) </p>
<p>// - Amplitudes: 0.3, 0.28, 0.25, 0.32 (different peak variations) </p>
<p>// - Noise frequencies: 3600, 3300, 3900, 2700 seconds (different fluctuation patterns) </p>
<p>// - This creates realistic load balancing effects where CPUs handle slightly different loads </p>
</html>", revisions="<html>
<ul>
<li>
November 16, 2022, by Michael Wetter:<br/>
Corrected control to avoid cooling tower pumps to operate when plant is off, because
shut-off valves are off when plant is off.
</li>
<li>
November 1, 2021, by Michael Wetter:<br/>
Corrected weather data bus connection which was structurally incorrect
and did not parse in OpenModelica.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2706\">issue 2706</a>.
</li>
<li>
December 1, 2017, by Yangyang Fu:<br/>
Removed redundant connection <code>connect(dpSet.y, pumSpe.u_s)</code>
</li>
<li>
July 30, 2017, by Yangyang Fu:<br/>
First implementation.
</li>
</ul>
</html>"),
experiment(
      StartTime=16416000,
      StopTime=17020800,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end IntegratedPrimaryLoadSideEconomizerCustomized;
