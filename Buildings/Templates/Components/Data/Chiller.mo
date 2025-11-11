within Buildings.Templates.Components.Data;
record Chiller
  "Record for chiller model"
  extends Modelica.Icons.Record;
  parameter Buildings.Templates.Components.Types.Chiller typ
    "Type of chiller"
    annotation (Evaluate=true,
    Dialog(group="Configuration", enable=false));
  parameter Modelica.Units.SI.MassFlowRate mChiWat_flow_nominal(
    final min=0)
    "CHW mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal(
    start=if typ == Buildings.Templates.Components.Types.Chiller.WaterCooled
      then mChiWat_flow_nominal elseif typ == Buildings.Templates.Components.Types.Chiller.AirCooled
      then Buildings.Templates.Data.Defaults.ratMFloAirByCapChi * abs(cap_nominal)
      else 0,
    final min=0)
    "Condenser cooling fluid (e.g. CW) mass flow rate"
    annotation (Dialog(group="Nominal condition",
      enable=typ==Buildings.Templates.Components.Types.Chiller.WaterCooled));
  parameter Modelica.Units.SI.HeatFlowRate cap_nominal
    "Cooling capacity"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.PressureDifference dpChiWat_nominal(
    final min=0,
    start=Buildings.Templates.Data.Defaults.dpChiWatChi)
    "CHW pressure drop"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.PressureDifference dpCon_nominal(
    final min=0,
    start=if typ == Buildings.Templates.Components.Types.Chiller.WaterCooled
      then Buildings.Templates.Data.Defaults.dpConWatChi
      elseif typ == Buildings.Templates.Components.Types.Chiller.AirCooled
      then Buildings.Templates.Data.Defaults.dpAirChi else 0)
    "Condenser cooling fluid pressure drop"
    annotation (Dialog(group="Nominal condition",
      enable=typ==Buildings.Templates.Components.Types.Chiller.WaterCooled));
  parameter Modelica.Units.SI.Temperature TChiWatSup_nominal(
    final min=260)
    "CHW supply temperature"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TCon_nominal(
    final min=273.15)
    "Condenser entering or leaving fluid temperature (depending on per.use_TConOutForTab)"
    annotation (Dialog(group="Nominal condition"));
  replaceable parameter
    Buildings.Fluid.Chillers.ModularReversible.Data.TableData2DLoadDep.Generic per(
      mCon_flow_nominal=mCon_flow_nominal,
      mEva_flow_nominal=mChiWat_flow_nominal,
      dpCon_nominal=dpCon_nominal,
      dpEva_nominal=dpChiWat_nominal,
      tabLowBou=[
        TCon_nominal - 30, TChiWatSup_nominal - 2;
        TCon_nominal + 10, TChiWatSup_nominal - 2],
      devIde="") constrainedby
    Buildings.Fluid.Chillers.ModularReversible.Data.TableData2DLoadDep.Generic
    "Cooling performance data"
    annotation (
    choicesAllMatching=true,
      Placement(transformation(extent={{-8,0},{8,16}})));
  parameter Modelica.Units.SI.Power P_min(final min=0)=0
    "Minimum power when system is enabled with compressor cycled off";
  annotation (
    defaultComponentPrefixes="parameter",
    defaultComponentName="datChi",
    Documentation(
      info="<html>
<p>
This record provides the set of sizing and operating parameters for
the classes within
<a href=\"modelica://Buildings.Templates.Components.Chillers\">
Buildings.Templates.Components.Chillers</a>.
It is composed of a set of parameters corresponding to the design
(selection) conditions and a sub-record <code>per</code> providing
the chiller performance data.
The design capacity is used to parameterize the chiller model.
The capacity (and power) computed from the external performance data file
is automatically scaled by the chiller model to match the value provided 
at design conditions.
</p>
<p>
The record allows two different parameterization logics, depending
on the value of the parameter <code>use_datDes</code>.
(The user can refer to the validation model
<a href=\"modelica://Buildings.Templates.Components.Validation.ChillersCompression\">
Buildings.Templates.Components.Chillers.Validation.Compression</a>
for an illustration of these two logics.)
</p>
<ul>
<li>
If <code>use_datDes=true</code> &ndash; default setting that should be
used in most cases: The performance data specified in the sub-record
<code>per</code> are \"translated\" so that the capacity and <i>COP</i>
calculated at design conditions match the design values
<code>cap_nominal</code> and <code>COP_nominal</code>.
The performance data that result from this translation are stored in
the sub-record <code>perSca</code> which is ultimately used by the chiller models within
<a href=\"modelica://Buildings.Templates.Components.Chillers\">
Buildings.Templates.Components.Chillers</a>.<br/>
Note that the performance data can be specified either by redeclaring
the sub-record <code>per</code>, or by simply assigning the performance
curves <code>per.capFunT</code>, <code>per.EIRFunT</code> and <code>per.EIRFunPLR</code>
in case these curves were calculated based on the design conditions.
To support the latter, the design conditions are propagated \"down\" to
the sub-record <code>per</code> but these bindings do not persist
after redeclaration so that a record at different rating conditions can
also be used.
</li>
<li>
If <code>use_datDes=false</code> &ndash; non-default setting that should only be
used if the rating conditions match the design conditions:
The rating conditions specified in the sub-record
<code>per</code> are propagated \"up\" (via the <code>start</code> attribute)
and used as design conditions.
The sub-record <code>perSca</code> which is ultimately used by the chiller models within
<a href=\"modelica://Buildings.Templates.Components.Chillers\">
Buildings.Templates.Components.Chillers</a>
is then identical to the sub-record <code>per</code>.
When using this logic, no assignment shall be made for the design
parameters, except for the design pressure drops <code>dp*_nominal</code>.
</li>
</ul>
<p>
note that placeholders values are assigned to the performance curves,
the reference source temperature and the input power in
cooling mode to avoid assigning these parameters in case of non-reversible
heat pumps.
These values are unrealistic and must be overwritten for reversible heat pumps, which
is always the case when redeclaring or
reassigning the performance record <code>per</code>.
Models that use this record will issue a warning if these placeholders values
are not overwritten in case of reversible heat pumps.
</p>
<p>
Note that placeholders values are assigned to the chiller performance curves
(<code>per.capFunT</code> , <code>per.EIRFunT</code> and <code>per.EIRFunPLR</code>)
to avoid assigning these parameters if
<code>typ=Buildings.Templates.Components.Types.Chiller.None</code>.
If the chiller type is not <code>None</code> these values are unrealistic
and must be overwritten, which is always the case when redeclaring or
reassigning the performance record <code>per</code>.
</p>
</html>"));
end Chiller;
