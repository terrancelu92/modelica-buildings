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
    TRacDifSet(y={TRacDifSetRan[i].y for i in 1:numChiDor}),
    XAirRetSet(y={0 for i in 1:numChiDor}),
    redeclare
      Buildings.Applications.DataCenters.ChillerCooled.Equipment.IntegratedPrimaryLoadSide
      chiWSE(addPowerToMedium=false, perPum=perPumPri),
    weaData(filNam=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")),
    rac(QRoo_flow=sca.y),
    ahuValSig(
      k=0.01,
      Ti=120,
      yMin=0.05,
      initType=Modelica.Blocks.Types.Init.InitialOutput,
      y_start=0.3),
    ahuFanSpeCon(
      Ti=120,
      yMin=0.05,
      initType=Modelica.Blocks.Types.Init.InitialOutput,
      y_start=0.3),
    ahu(yFan_start=1),
    varSpeCon(tWai=0),
    TAirSupSet(y={0 + 273.15 for i in 1:numChiDor}),
    hea(Q_flow_nominal=-150000),
    TCHWSupOve(activate(y=true),  uExt(y=TSupCHW.y)),
    TCHWSupSet(k=18 + 273.15),
    add(k1=-1),
    TRoo(y=TRooSetRan.y),
    TRacOut(y={TRacOutRan[i].y for i in 1:numChiDor}));

  parameter Buildings.Fluid.Movers.Data.Generic[numChi] perPumPri(
    each pressure=Buildings.Fluid.Movers.BaseClasses.Characteristics.flowParameters(
          V_flow=m2_flow_chi_nominal/1000*{0.2,0.6,1.0,1.2},
          dp=(dp2_chi_nominal+dp2_wse_nominal+18000)*{1.5,1.3,1.0,0.6}))
    "Performance data for primary pumps";

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
  BaseClasses.SignalStep TRacDifSetRan[numChiDor](
    yMin=5,
    yMax=15,
    sampleTime={3000,3000,2100,2700,2400,2400,3300,3000,3000,3300,3600,3300,
        3300,3600,3300,3300,2100,2400,3000,2400}[1:numChiDor],
    randomSeed={6,91,900,6138,80687,9,70,623,8472,60694,3,11,314,2045,96255,3,
        32,398,7723,87754}[1:numChiDor],
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{78,-140},{98,-120}})));
  BaseClasses.SignalStep TRacOutRan[numChiDor](
    yMin=22 + 273.15,
    yMax=26 + 273.15,
    sampleTime={3600,3600,2400,3600,3000,2100,3600,2100,3000,3600,3000,3300,2100,
        3300,2400,1800,3000,3600,2100,2400}[1:numChiDor],
    randomSeed={5,50,360,6914,55328,9,53,140,6088,99611,2,64,769,5453,71289,2,89,
        897,4447,71666}[1:numChiDor],
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{80,-180},{100,-160}})));
  BaseClasses.SignalStep TRooSetRan(
    yMin=273.15 + 22,
    yMax=273.15 + 26,
    sampleTime=3600,
    randomSeed=3444,
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{80,-220},{100,-200}})));
  Modelica.Blocks.Sources.CombiTimeTable PCPU(
    tableOnFile=true,
    tableName="tab1",
    fileName=ModelicaServices.ExternalReferences.loadResource("modelica://Buildings/Resources/Data/Applications/DataCenters/ChillerCooled/Examples/Power.txt"),
    columns=2:numChiDor + 1,
    startTime(displayUnit="d"),
    shiftTime(displayUnit="d") = 15552000)
    annotation (Placement(transformation(extent={{-120,-240},{-100,-220}})));

  Modelica.Blocks.Math.Gain sca[numChiDor](k=1000)  "Gain effect"
    annotation (Placement(transformation(extent={{-80,-240},{-60,-220}})));
  BaseClasses.SignalStep TSupCHW(
    yMin=12 + 273.15,
    yMax=20 + 273.15,
    sampleTime=9000,
    randomSeed=125,
    usePredefPattern=false)
    annotation (Placement(transformation(extent={{80,-260},{100,-240}})));
  Modelica.Blocks.Sources.IntegerExpression cooModCon(y=3)
    "Cooling mode controller"
    annotation (Placement(transformation(extent={{-254,100},{-232,122}})));
equation

  connect(pumSpeSig.y, chiWSE.yPum)
    annotation (Line(
      points={{-99,-10},{-60,-10},{-60,25.6},{-1.6,25.6}},
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
  connect(TCHWRet.port_b, chiWSE.port_a2)
    annotation (Line(
      points={{80,0},{40,0},{40,24},{20,24}},
      color={0,127,255},
      thickness=0.5));

  connect(TCHWSup.T, chiStaCon.TCHWSup)
    annotation (Line(
      points={{-26,11},{-26,18},{-182,18},{-182,134},{-172,134}},
      color={0,0,127}));
  connect(yVal5.y, chiWSE.yVal5) annotation (Line(points={{-139,40},{-84,40},{
          -84,33},{-1.6,33}}, color={0,0,127}));
  connect(yVal6.y, chiWSE.yVal6) annotation (Line(points={{-139,24},{-84,24},{
          -84,29.8},{-1.6,29.8}}, color={0,0,127}));
  for i in 1:numChiDor loop
  connect(PCPU.y[i], sca[i].u)
    annotation (Line(points={{-99,-230},{-82,-230}}, color={0,0,127}));
  end for;
  connect(cooModCon.y, intToBoo.u) annotation (Line(points={{-230.9,111},{-202.45,
          111},{-202.45,110},{-172,110}}, color={255,127,0}));
  connect(cooModCon.y, chiStaCon.cooMod) annotation (Line(points={{-230.9,111},{
          -201.45,111},{-201.45,146},{-172,146}}, color={255,127,0}));
  connect(cooModCon.y, cooTowSpeCon.cooMod) annotation (Line(points={{-230.9,
          111},{-198,111},{-198,182.444},{-172,182.444}},
                                                     color={255,127,0}));
  connect(cooModCon.y, CWPumCon.cooMod) annotation (Line(points={{-230.9,111},{-198,
          111},{-198,76},{-174,76}}, color={255,127,0}));
  connect(cooModCon.y, sigCha.u) annotation (Line(points={{-230.9,111},{-208,111},
          {-208,192},{132,192},{132,160},{178,160}}, color={255,127,0}));
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
      StartTime=15552000,
      StopTime=19008000,
      Interval=299.999808,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end IntegratedPrimaryLoadSideEconomizerCustomized;
