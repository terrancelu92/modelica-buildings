within Buildings.Templates.Plants.HeatPumps.Validation;
model FourPipeASHP_with_controls_templatemodel_signalBus
  "Validation of AWHP plant template"
  extends Buildings.Fluid.Interfaces.PartialFourPortInterface(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium);
  replaceable package Medium=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";
  replaceable package MediumAir=Buildings.Media.Air
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";
  parameter Real mHeaWatPri_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal;
  parameter Real mChiWatPri_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal;
  parameter Boolean have_chiWat=true
    "Set to true if the plant provides CHW"
    annotation (Evaluate=true,
    Dialog(group="Configuration"));
  inner parameter UserProject.Data.AllSystems datAll
    "Plant parameters"
    annotation (Placement(transformation(extent={{144,40},{164,60}})));

  parameter Boolean allowFlowReversal=true
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation (Dialog(tab="Assumptions"),
    Evaluate=true);
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation (Evaluate=true,
    Dialog(tab="Dynamics",group="Conservation equations"));

  parameter Modelica.Units.SI.Temperature THwSup_nominal=323.15
    "HW supply temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature THwRet_nominal=315.15
    "HW return temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TChwSup_nominal=280.15
    "CHW supply temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TChwRet_nominal=285.15
    "CHW return temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TAmbHea_nominal=268.15
    "OA temperature"
    annotation (Dialog(group="Nominal condition - Heating mode"));
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal = 58E3
    "Heating heat flow rate - Heating mode"
    annotation (Dialog(group="Nominal condition - Heating mode"));
  parameter Modelica.Units.SI.HeatFlowRate QHeaShc_flow_nominal = 85E3
    "Heating heat flow rate - SHC mode"
    annotation (Dialog(group="Nominal condition - Heating mode"));
  parameter Modelica.Units.SI.Temperature TAmbCoo_nominal=308.15
    "Ambient side fluid temperature — Entering or leaving depending on use_TAmbOutForTab"
    annotation (Dialog(group="Nominal condition - Cooling mode"));
  parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal = -73E3
    "Cooling heat flow rate - Cooling mode"
    annotation (Dialog(group="Nominal condition - Cooling mode"));
  parameter Modelica.Units.SI.HeatFlowRate QCooShc_flow_nominal = -65E3
    "Cooling heat flow rate - SHC mode"
    annotation (Dialog(group="Nominal condition - Cooling mode"));
  parameter Modelica.Units.SI.MassFlowRate mHw_flow_nominal=
    QHea_flow_nominal / (THwSup_nominal - THwRet_nominal) /
    Buildings.Media.Water.cp_const
    "HW mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.MassFlowRate mChw_flow_nominal=
    QCoo_flow_nominal / (TChwSup_nominal - TChwRet_nominal) /
    Buildings.Media.Water.cp_const
    "CHW mass flow rate"
    annotation (Dialog(group="Nominal condition"));

  Fluid.FixedResistances.CheckValve cheVal(
    redeclare package Medium = Medium,
    m_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal,
    dpValve_nominal=500,
    dpFixed_nominal=40000)
    annotation (Placement(transformation(extent={{-66,-290},{-46,-270}})));
  Fluid.Movers.Preconfigured.SpeedControlled_y     mov1(
    redeclare package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal,
    dp_nominal=datAll.pla.pumHeaWatPri.dp_nominal[1])
    annotation (Placement(transformation(extent={{-38,-270},{-18,-290}})));
  Fluid.Movers.Preconfigured.SpeedControlled_y     mov2(
    redeclare package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal,
    dp_nominal=datAll.pla.pumChiWatPri.dp_nominal[1])
    annotation (Placement(transformation(extent={{82,-260},{62,-240}})));
  Fluid.FixedResistances.CheckValve cheVal1(
    redeclare package Medium = Medium,
    m_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal,
    dpValve_nominal=500,
    dpFixed_nominal=40000)
    annotation (Placement(transformation(extent={{112,-260},{92,-240}})));

  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{-118,-220},{-98,-200}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(t=0.05, h=0.02)
    annotation (Placement(transformation(extent={{140,-212},{160,-192}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr1(t=0.05, h=0.02)
    annotation (Placement(transformation(extent={{62,-350},{82,-330}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr2(t=50, h=10)
    annotation (Placement(transformation(extent={{92,-130},{112,-110}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1
    annotation (Placement(transformation(extent={{-78,-420},{-58,-400}})));
  Buildings.Controls.OBC.CDL.Routing.IntegerExtractor extIndInt(nin=3)
    annotation (Placement(transformation(extent={{-296,-286},{-276,-266}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt[3](k={Buildings.Fluid.HeatPumps.ModularReversible.Types.OperatingModes.cooling,
        Buildings.Fluid.HeatPumps.ModularReversible.Types.OperatingModes.heating,
        Buildings.Fluid.HeatPumps.ModularReversible.Types.OperatingModes.shc})
    annotation (Placement(transformation(extent={{-334,-286},{-314,-266}})));
  Fluid.Sensors.TemperatureTwoPort senTem(redeclare package Medium = Medium,
      m_flow_nominal=datAll.pla.hp.mChiWatHp_flow_nominal) annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={-38,-140})));
  Fluid.Sensors.TemperatureTwoPort senTem1(redeclare package Medium = Medium,
      m_flow_nominal=datAll.pla.hp.mHeaWatHp_flow_nominal) annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={132,-158})));

  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr4(t=278)
    annotation (Placement(transformation(extent={{-18,-150},{2,-130}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea9
    annotation (Placement(transformation(extent={{22,-150},{42,-130}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(t=273.15 + 70)
    annotation (Placement(transformation(extent={{122,-30},{142,-10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea10
    annotation (Placement(transformation(extent={{162,-30},{182,-10}})));
  BoundaryConditions.WeatherData.Bus
      weaBus "Weather data bus" annotation (Placement(transformation(extent={{-236,
            -30},{-162,40}}),   iconTransformation(extent={{-114,-44},{-76,-6}})));
  Buildings.Templates.Components.HeatPumps.AirToWaterSHC hpSHC(
    redeclare package MediumHeaWat = Medium,
    redeclare package MediumSou = Medium,
    final energyDynamics=energyDynamics,
    nUni=3,
    final dat=datHpSHC) "Multipipe heat pump"
    annotation (Placement(transformation(extent={{6,-270},{26,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul
    annotation (Placement(transformation(extent={{-66,-180},{-46,-160}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul1
    annotation (Placement(transformation(extent={{-38,-440},{-18,-420}})));
  parameter Buildings.Templates.Components.Data.HeatPump datHpSHC(
    final cpHeaWat_default=hpSHC.cpHeaWat_default,
    final cpSou_default=hpSHC.cpSou_default,
    final typ=hpSHC.typ,
    final is_rev=hpSHC.is_rev,
    mChiWat_flow_nominal=mChw_flow_nominal,
    dpChiWat_nominal(displayUnit="bar") = 40000,
    capCoo_nominal=QCooShc_flow_nominal,
    TChiWatSup_nominal=TChwSup_nominal,
    TSouCoo_nominal=TAmbCoo_nominal,
    perSHC(
      fileNameHea=Modelica.Utilities.Files.loadResource(
          "modelica://Buildings/Resources/Data/Fluid/HeatPumps/ModularReversible/RefrigerantCycle/BaseClasses/Validation/AWHP_Heating.txt"),
      fileNameCoo=Modelica.Utilities.Files.loadResource(
          "modelica://Buildings/Resources/Data/Fluid/HeatPumps/ModularReversible/RefrigerantCycle/BaseClasses/Validation/AWHP_Cooling.txt"),
      fileNameShc=Modelica.Utilities.Files.loadResource(
          "modelica://Buildings/Resources/Data/Fluid/HeatPumps/ModularReversible/RefrigerantCycle/BaseClasses/Validation/AWHP_SHC.txt")),
    mHeaWat_flow_nominal=mHw_flow_nominal,
    dpHeaWat_nominal(displayUnit="bar") = 30000,
    capHea_nominal=QHeaShc_flow_nominal,
    THeaWatSup_nominal=THwSup_nominal,
    TSouHea_nominal=TAmbHea_nominal,
    dpSouWwHea_nominal(displayUnit="Pa"))
    "Simultaneous heating and cooling (SHC) air-to-water heat pump record"
    annotation (Placement(transformation(extent={{-180,-68},{-160,-48}})));
  Buildings.Templates.Components.Interfaces.Bus busHpSHC
    "SHC air-to-water heat pump control bus" annotation (Placement(
        transformation(extent={{-240,-364},{-200,-324}}),
                                                      iconTransformation(extent={{-116,
            -14},{-76,26}})));
equation
  if have_chiWat then
  end if;
  connect(cheVal.port_b, mov1.port_a)
    annotation (Line(points={{-46,-280},{-38,-280}},   color={162,29,33}));
  connect(cheVal1.port_b, mov2.port_a)
    annotation (Line(points={{92,-250},{82,-250}},   color={0,127,255}));
  connect(conInt.y, extIndInt.u)
    annotation (Line(points={{-312,-276},{-298,-276}},
                                                 color={255,127,0}));

  connect(mov2.y_actual, greThr.u) annotation (Line(points={{61,-243},{44,-243},
          {44,-202},{138,-202}},
                        color={0,0,127}));
  connect(mov1.y_actual, greThr1.u) annotation (Line(points={{-17,-287},{-10,
          -287},{-10,-340},{60,-340}},                                  color={0,
          0,127}));

  connect(senTem.T, greThr4.u) annotation (Line(points={{-27,-140},{-20,-140}},
                                    color={0,0,127}));
  connect(greThr4.y, booToRea9.u)
    annotation (Line(points={{4,-140},{20,-140}},      color={255,0,255}));
  connect(lesThr.y, booToRea10.u)
    annotation (Line(points={{144,-20},{160,-20}},     color={255,0,255}));
  connect(senTem1.T, lesThr.u) annotation (Line(points={{143,-158},{150,-158},{
          150,-40},{114,-40},{114,-20},{120,-20}},
                                          color={0,0,127}));
  connect(cheVal.port_a, port_a2) annotation (Line(points={{-66,-280},{-74,-280},
          {-74,-76},{82,-76},{82,-60},{100,-60}},
        color={162,29,33}));
  connect(senTem1.port_b, port_b2) annotation (Line(points={{132,-148},{132,-46},
          {-100,-46},{-100,-60}},           color={255,170,170}));
  connect(cheVal1.port_a, port_a1) annotation (Line(points={{112,-250},{118,
          -250},{118,-80},{-118,-80},{-118,60},{-100,60}},
                                                     color={0,127,255}));
  connect(senTem.port_b, port_b1)
    annotation (Line(points={{-38,-130},{-38,60},{100,60}},
                                                        color={0,127,255}));
  connect(booToRea1.y, mul1.u1) annotation (Line(points={{-56,-410},{-48,-410},
          {-48,-424},{-40,-424}},            color={0,0,127}));
  connect(mul1.y, mov1.y) annotation (Line(points={{-16,-430},{-10,-430},{-10,
          -344},{-14,-344},{-14,-300},{-28,-300},{-28,-292}}, color={0,0,127}));
  connect(booToRea.y, mul.u2) annotation (Line(points={{-96,-210},{-90,-210},{
          -90,-176},{-68,-176}}, color={0,0,127}));
  connect(mul.y, mov2.y) annotation (Line(points={{-44,-170},{66,-170},{66,-232},
          {72,-232},{72,-238}}, color={0,0,127}));
  connect(hpSHC.port_a, mov1.port_b)
    annotation (Line(points={{6,-280},{-18,-280}}, color={162,29,33}));
  connect(hpSHC.port_b, senTem1.port_a) annotation (Line(points={{26,-280},{132,
          -280},{132,-168}}, color={255,170,170}));
  connect(hpSHC.port_aSou, mov2.port_b) annotation (Line(points={{26,-270},{48,
          -270},{48,-250},{62,-250}}, color={0,127,255}));
  connect(hpSHC.port_bSou, senTem.port_a) annotation (Line(points={{6,-270},{
          -38,-270},{-38,-150}}, color={0,127,255}));
  connect(weaBus, hpSHC.busWea) annotation (Line(
      points={{-199,5},{-200,5},{-200,-228},{-4,-228},{-4,-300},{10,-300},{10,
          -290}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(busHpSHC, hpSHC.bus) annotation (Line(
      points={{-220,-344},{16,-344},{16,-290}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(greThr2.u, busHpSHC.P) annotation (Line(points={{90,-120},{-220,-120},
          {-220,-344}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(extIndInt.y, busHpSHC.mode) annotation (Line(points={{-274,-276},{
          -252,-276},{-252,-344},{-220,-344}}, color={255,127,0}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(mul1.u2, busHpSHC.uPumConSpe) annotation (Line(points={{-40,-436},{
          -156,-436},{-156,-400},{-220,-400},{-220,-344}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(booToRea1.u, busHpSHC.u1PumConEna) annotation (Line(points={{-80,-410},
          {-134,-410},{-134,-344},{-220,-344}},            color={255,0,255}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(extIndInt.index, busHpSHC.uPlaOpeMod) annotation (Line(points={{-286,
          -288},{-286,-378},{-220,-378},{-220,-344}}, color={255,127,0}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(booToRea.u, busHpSHC.u1PumEvaEna) annotation (Line(points={{-120,-210},
          {-220,-210},{-220,-344}}, color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(mul.u1, busHpSHC.uPumEvaSpe) annotation (Line(points={{-68,-164},{
          -220,-164},{-220,-344}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(greThr1.y, busHpSHC.yPumConEnaPro) annotation (Line(points={{84,-340},
          {100,-340},{100,-376},{-220,-376},{-220,-344}}, color={255,0,255}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(greThr.y, busHpSHC.yPumEvaEnaPro) annotation (Line(points={{162,-202},
          {166,-202},{166,-370},{-220,-370},{-220,-344}}, color={255,0,255}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(greThr2.y, busHpSHC.yHPEnaPro) annotation (Line(points={{114,-120},{
          174,-120},{174,-390},{-220,-390},{-220,-344}}, color={255,0,255}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  annotation (
    __Dymola_Commands(
      file=
        "modelica://Buildings/Resources/Scripts/Dymola/Templates/Plants/HeatPumps/Validation/AirToWater.mos"
        "Simulate and plot"),
    experiment(
      StartTime=11145600,
      StopTime=11750400,
      Interval=600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Documentation(
      info="<html>
<p>
This model validates
<a href=\"modelica://Buildings.Templates.Plants.HeatPumps.AirToWater\">
Buildings.Templates.Plants.HeatPumps.AirToWater</a>
by simulating a <i>24</i>-hour period with overlapping heating and
cooling loads.
The heating loads reach their peak value first, the cooling loads reach it last.
</p>
<p>
Three equally sized heat pumps are modeled, which can all be lead/lag alternated.
A heat recovery chiller is included (<code>pla.have_hrc_select=true</code>) 
and connected to the HW and CHW return pipes (sidestream integration).
A unique aggregated load is modeled on each loop by means of a cooling or heating
component controlled to maintain a constant <i>&Delta;T</i>
and a modulating valve controlled to track a prescribed flow rate.
An importance multiplier of <i>10</i> is applied to the plant requests
and reset requests generated from the valve position.
</p>
<p>
The user can toggle the top-level parameter <code>have_chiWat</code>
to switch between a cooling and heating system (the default setting)
to a heating-only system.
Advanced equipment and control options can be modified via the parameter
dialog of the plant component.
</p>
<p>
Simulating this model shows how the plant responds to a varying load by
</p>
<ul>
<li>
staging or unstaging the AWHPs and associated primary pumps,
</li>
<li>
rotating lead/lag alternate equipment to ensure even wear,
</li>
<li>
resetting the supply temperature and remote differential pressure
in both the CHW and HW loops based on the valve position,
</li>
<li>
staging and controlling the secondary pumps to meet the
remote differential pressure setpoint.
</li>
</ul>
<h4>Details</h4>
<p>
By default, all valves within the plant are modeled considering a linear
variation of the pressure drop with the flow rate (<code>pla.linearized=true</code>),
as opposed to the quadratic relationship usually considered for
a turbulent flow regime.
By limiting the size of the system of nonlinear equations, this setting
reduces the risk of solver failure and the time to solution for testing
various plant configurations.
</p>
</html>",
      revisions="<html>
<ul>
<li>
May 31, 2024, by Antoine Gautier:<br/>
Added sidestream HRC and refactored the model after updating the HP plant template.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3808\">#3808</a>.
</li>
<li>
March 29, 2024, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(
      coordinateSystem(
        extent={{-340,-460},{240,80}},
        preserveAspectRatio=false,
        grid={2,2})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}, preserveAspectRatio=
            false),                                        graphics={Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-34},{100,-88}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,84},{100,30}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid)}));
end FourPipeASHP_with_controls_templatemodel_signalBus;
