# 49.5 kWp Industrial Rooftop PV - Garment Factory, Gazipur
# SketchUp 3D model build script. Usage (Ruby Console):
#   load "C:/Users/<you>/Downloads/P2_Gazipur_50kWp_Industrial_SketchUp_model.rb"
model = Sketchup.active_model
model.start_operation("Build 49.5 kWp industrial rooftop, Gazipur", true)
ents = model.active_entities
def mat(model, name, rgb)
  m = model.materials[name] || model.materials.add(name)
  m.color = Sketchup::Color.new(*rgb)
  m
end
def pt(x, y, z) Geom::Point3d.new(x.m, y.m, z.m) end
def box(ents, name, x, y, z, dx, dy, dz, material)
  g = ents.add_group
  g.name = name
  f = g.entities.add_face([pt(x, y, z), pt(x + dx, y, z), pt(x + dx, y + dy, z), pt(x, y + dy, z)])
  f.reverse! if f.normal.z < 0
  f.pushpull(dz.m)
  g.material = material
  g
end
m_pv = mat(model, "PV_module_blue", [31, 58, 107])
m_fr = mat(model, "PV_frame", [190, 190, 190])


def pv_def(model, name, tilt, m_pv, m_fr)
  d = model.definitions[name] || model.definitions.add(name)
  return d if d.entities.length > 0
  w, l = 1.134, 2.278
  dep, h = l * Math.cos(tilt * Math::PI / 180), l * Math.sin(tilt * Math::PI / 180)
  f = d.entities.add_face([pt(0, 0, 0), pt(w, 0, 0), pt(w, dep, h), pt(0, dep, h)])
  f.reverse! if f.normal.z < 0
  f.pushpull(0.035.m)
  d.entities.grep(Sketchup::Face).each { |fc| fc.material = m_fr; fc.back_material = m_fr }
  d.entities.grep(Sketchup::Face).max_by { |fc| fc.bounds.max.z + fc.normal.z }.material = m_pv
  d
end

m_bld = mat(model, "m_bld", [205, 205, 200])
m_obs = mat(model, "m_obs", [150, 150, 150])
m_sky = mat(model, "m_sky", [175, 205, 230])
box(ents, "Factory shed 60x30x9 m", 0, 0, 0, 60, 30, 9, m_bld)
box(ents, "Skylight strip", 10, 22, 9, 40, 1.2, 0.15, m_sky)
box(ents, "Ventilator V1", 10, 25.5, 9, 1.0, 1.0, 1.2, m_obs)
box(ents, "Ventilator V2", 22, 25.5, 9, 1.0, 1.0, 1.2, m_obs)
box(ents, "Ventilator V3", 34, 25.5, 9, 1.0, 1.0, 1.2, m_obs)
box(ents, "Ventilator V4", 46, 25.5, 9, 1.0, 1.0, 1.2, m_obs)
defn = pv_def(model, "PV_550W_5deg", 5, m_pv, m_fr)
rg = ents.add_group; rg.name = "Row 1 - 30 modules"
30.times { |i| rg.entities.add_instance(defn, Geom::Transformation.new(pt(12.7 + i * 1.154, 8.0, 9.15))) }
rg = ents.add_group; rg.name = "Row 2 - 30 modules"
30.times { |i| rg.entities.add_instance(defn, Geom::Transformation.new(pt(12.7 + i * 1.154, 11.269331522252996, 9.15))) }
rg = ents.add_group; rg.name = "Row 3 - 30 modules"
30.times { |i| rg.entities.add_instance(defn, Geom::Transformation.new(pt(12.7 + i * 1.154, 14.538663044505991, 9.15))) }

si = model.shadow_info
si["City"] = "Gazipur"; si["Country"] = "Bangladesh"
si["Latitude"] = 23.99; si["Longitude"] = 90.42; si["TZOffset"] = 6.0
si["DisplayShadows"] = true
model.active_view.camera = Sketchup::Camera.new(pt(95, -45, 55), pt(30, 15, 8), Z_AXIS)
# ShadowTime is stored in UTC: local Dhaka time minus 6 h
[["Dec21 09-00", 12, 21, 3], ["Dec21 12-00", 12, 21, 6], ["Dec21 15-00", 12, 21, 9], ["Jun21 07-00", 6, 21, 1]].each do |nm, mo, dy, hr|
  si["ShadowTime"] = Time.gm(2026, mo, dy, hr, 0)
  pg = model.pages[nm] || model.pages.add(nm)
  pg.update
end
model.pages.selected_page = model.pages["Dec21 09-00"]
model.commit_operation
puts "Done: 49.5 kWp industrial rooftop, Gazipur"
