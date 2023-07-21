within Buildings.Templates.Components.OutdoorAirMixer.Examples.BaseClasses;
partial block PartialVAVMultizone
  "Interface class for multiple-zone VAV controller"
  extends
    Buildings.Templates.AirHandlersFans.Components.Controls.Interfaces.PartialController(
      redeclare Buildings.Templates.AirHandlersFans.Components.Data.VAVMultiZoneController
        dat(
          typSecOut=Buildings.Controls.OBC.ASHRAE.G36.Types.OutdoorAirSection.SingleDamper,
          buiPreCon=buiPreCon,
          stdVen=stdVen));

  outer replaceable Buildings.Templates.Components.Coils.None coiCoo
    "Cooling coil";
  outer replaceable Buildings.Templates.Components.Coils.None coiHeaPre
    "Heating coil (preheat position)";
  outer replaceable Buildings.Templates.Components.Coils.None coiHeaReh
    "Heating coil (reheat position)";

  parameter Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer typCtlEco=
    Buildings.Controls.OBC.ASHRAE.G36.Types.ControlEconomizer.FixedDryBulb
    "Economizer control type"
    annotation (Evaluate=true,
      Dialog(
        group="Economizer",
        enable=false));

  parameter Buildings.Templates.AirHandlersFans.Types.ControlFanReturn typCtlFanRet=
    Buildings.Templates.AirHandlersFans.Types.ControlFanReturn.AirflowMeasured
    "Return fan control type"
    annotation (Evaluate=true,
      Dialog(
        group="Configuration",
        enable=typFanRet <> Buildings.Templates.Components.Types.Fan.None));

  parameter Boolean use_TMix=true
    "Set to true if mixed air temperature measurement is enabled"
    annotation(Dialog(
     group="Economizer",
     enable=typ<>Buildings.Templates.AirHandlersFans.Types.Controller.G36VAVMultiZone));

  parameter Boolean have_frePro=true
    "Set to true to include freeze protection"
    annotation(Evaluate=true);

  parameter Buildings.Controls.OBC.ASHRAE.G36.Types.FreezeStat typFreSta=
    Buildings.Controls.OBC.ASHRAE.G36.Types.FreezeStat.No_freeze_stat
    "Option for low limit (freeze) protection"
    annotation(Evaluate=true, Dialog(enable=have_frePro));

  final parameter Buildings.Controls.OBC.ASHRAE.G36.Types.OutdoorAirSection typSecOut=
    Buildings.Controls.OBC.ASHRAE.G36.Types.OutdoorAirSection.SingleDamper
    "Type of outdoor air section"
    annotation (Dialog(group="Economizer"));

  final parameter Buildings.Controls.OBC.ASHRAE.G36.Types.BuildingPressureControlTypes buiPreCon=
  Buildings.Controls.OBC.ASHRAE.G36.Types.BuildingPressureControlTypes.ReliefDamper
    "Type of building pressure control system"
    annotation (Dialog(group="Economizer"));

  final parameter Buildings.Controls.OBC.ASHRAE.G36.Types.EnergyStandard stdEne=
    datAll.stdEne
    "Energy standard"
    annotation(Dialog(enable=
    typ==Buildings.Templates.AirHandlersFans.Types.Controller.G36VAVMultiZone),
    Evaluate=true);

  final parameter Buildings.Controls.OBC.ASHRAE.G36.Types.VentilationStandard stdVen=
    datAll.stdVen
    "Ventilation standard"
    annotation(Dialog(enable=
    typ==Buildings.Templates.AirHandlersFans.Types.Controller.G36VAVMultiZone),
    Evaluate=true);

  parameter Boolean have_CO2Sen=false
    "Set to true if there are zones with CO2 sensor"
    annotation (Dialog(group="Configuration",
      enable=
      typ==Buildings.Templates.AirHandlersFans.Types.Controller.G36VAVMultiZone and
      typSecOut==Buildings.Controls.OBC.ASHRAE.G36.Types.OutdoorAirSection.DedicatedDampersPressure and
      stdVen==Buildings.Controls.OBC.ASHRAE.G36.Types.VentilationStandard.California_Title_24));

initial equation
  if typ==Buildings.Templates.AirHandlersFans.Types.Controller.G36VAVMultiZone then
    // We check the fallback "else" clause.
    if buiPreCon==Buildings.Controls.OBC.ASHRAE.G36.Types.BuildingPressureControlTypes.ReliefDamper then
      assert(true,
       "In "+ getInstanceName() + ": "+
       "The system configuration is incompatible with available options for building pressure control.");
    end if;
  end if;

  annotation (Documentation(info="<html>
<p>
This partial class provides a standard interface for multiple-zone VAV controllers.
</p>
</html>"));
end PartialVAVMultizone;
