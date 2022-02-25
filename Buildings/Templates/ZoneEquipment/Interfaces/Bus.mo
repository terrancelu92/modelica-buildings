within Buildings.Templates.ZoneEquipment.Interfaces;
expandable connector Bus "Main control bus"
  extends Modelica.Icons.SignalBus;

  Templates.Components.Interfaces.Bus damVAV
    "VAV damper points"
    annotation (HideResult=false);

  Templates.Components.Interfaces.Bus coiHea
    "Heating coil points"
    annotation (HideResult=false);

  annotation (
    defaultComponentName="bus");
end Bus;