const maths_vec = @import("maths_vec.zig");
const data_handle = @import("data_handle.zig");
const data_color = @import("data_color.zig");

const Vec3f32 = maths_vec.Vec3f32;
const Color = data_color.Color;

pub const MaterialEnum = enum {
    Lambertian,
    DiffuseLight,
    Metal,
    Dielectric,
    Phong,
};

pub const ShapeEnum = enum {
    ImplicitSphere,
    ImplicitPlane,
};

pub const CameraEnum = enum {
    Perspective,
    Orthographic,
};

pub const EnvironmentEnum = enum {
    SkyDome,
};

pub const AovStandardEnum = enum {
    Beauty,
    Albedo,
    Alpha,
    Depth,
    Normal,

    Direct,
    Indirect,

    Emission,

    Diffuse,
    DiffuseDirect,
    DiffuseIndirect,

    Specular,
    SpecularDirect,
    SpecularIndirect,

    Transmission,

    DebugCheeseNan,
    DebugTimePerPixel,
};

pub const AovStandardNonRaytraced = [_]AovStandardEnum{
    .Albedo,
    .Alpha,
    .Depth,
    .Normal,
    .DebugCheeseNan,
    .DebugTimePerPixel,
};

pub const LightDecayMode = enum {
    NoDecay,
    Quadratic,
};
pub const Material = union(MaterialEnum) {
    Lambertian: struct {
        base: f32 = 0.7,
        base_color: Color = data_color.COLOR_GREY,
        ambiant: f32 = 0.05,
    },
    DiffuseLight: struct {
        intensity: f32 = 0.7,
        exposition: f32 = 0,
        color: Color = data_color.COLOR_GREY,
        decay_mode: LightDecayMode = LightDecayMode.NoDecay,
    },
    Metal: struct {
        base: f32 = 0.7,
        base_color: Color = data_color.COLOR_GREY,
        ambiant: f32 = 0.05,
        fuzz: f32 = 0,
    },
    Dielectric: struct {
        base_color: Color = data_color.COLOR_GREY,
        ior: f32 = 1,
    },
    Phong: struct {},
};

pub const Shape = union(ShapeEnum) {
    ImplicitSphere: struct {
        radius: f32 = 10,
    },
    ImplicitPlane: struct {
        normal: Vec3f32 = Vec3f32.create_y(),
    },
};

pub const Camera = union(CameraEnum) {
    Perspective: struct {
        focal_length: f32 = 10,
        field_of_view: f32 = 60,
    },
    Orthographic: struct {},
};

pub const Environment = union(EnvironmentEnum) {
    SkyDome: struct {
        handle_material: data_handle.HandleMaterial,
    },
};
