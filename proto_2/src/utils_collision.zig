const constants = @import("constants.zig");
const maths_vec = @import("maths_vec.zig");
const maths = @import("maths.zig");

const EPSILON = constants.EPSILON;

pub const HitResult = struct {
    hit: u1,
    t: f32,
};

pub fn check_ray_hit_implicit_sphere(
    ray_direction: maths_vec.Vec3f32,
    ray_origin: maths_vec.Vec3f32,
    sphere_position: maths_vec.Vec3f32,
    sphere_radius: f32,
) !HitResult {

    // - equation of the ray is : ray_origin + t * ray_direction = P
    //   where t is a scalar and p a Vec3f32 position on the 3d space.
    // - equation of the sphere is: (P - sphere_position) ^2 - r^2 = 0
    //   therefore we want to resolve : (ray_origin + t * ray_direction - sphere_position)^2 - r^2 = 0
    //   which is quatratic equation at^2 + bt + c = 0 where:
    //   a = ray_direction^2
    //   b = 2 * ray_direction * (ray_origin - sphere_position)
    //   c = (ray_origin - sphere_position) ^2 - r^2

    const L = ray_origin.substract_vector(sphere_position);
    // from ray origin to sphere center

    const a: f32 = ray_direction.product_dot(ray_direction);
    const b: f32 = 2 * (ray_direction.product_dot(L));
    const c: f32 = L.product_dot(L) - (sphere_radius * sphere_radius);

    const solution = try maths.solve_quadratic(a, b, c);
    const solution_number = solution.@"0";

    switch (solution_number) {
        0 => return .{ .hit = 0, .t = 0 },
        1 => return .{ .hit = 1, .t = solution.@"1" },
        2 => return .{ .hit = 1, .t = solution.@"1" }, // assuming smaller solution is always on field 1.
        inline else => unreachable,
    }
}

pub fn check_ray_hit_implicit_plane(
    ray_direction: maths_vec.Vec3f32,
    ray_origin: maths_vec.Vec3f32,
    plane_position: maths_vec.Vec3f32,
    plane_normal: maths_vec.Vec3f32,
) !HitResult {

    // - equation of the ray is : ray_origin + t * ray_direction = P
    //   where t is a scalar and p a Vec3f32 position on the 3d space.
    // - equation of the plane is: (P - plane_position) * plane_normal = 0
    // therefore we want to resolve:
    // (ray_origin + t * ray_direction - plane_position) * plane_normal = 0
    // t * ray_direction * plane_normal  =  - (ray_origin - plane_position) * plane_normal
    // t = ((plane_position - ray_origin) * plane_normal) / (ray_direction * plane_normal)

    // no solution if ray_direction dot plane_normal == 0 (if there are colinear, no intersection)
    // we only consider t > 0.

    const denominator = ray_direction.product_dot(plane_normal);

    // TODO: use "almost equal".
    if (denominator < EPSILON and denominator > EPSILON) { // absolute!
        return .{ .hit = 0, .t = 0 };
    }

    var _tmp = plane_position.substract_vector(ray_origin);
    const numerator = _tmp.product_dot(plane_normal);

    const t: f32 = numerator / denominator;

    if (t <= EPSILON) return .{ .hit = 0, .t = 0 };

    return .{ .hit = 1, .t = t };
}

pub fn check_ray_hit_skydome(ray_direction: maths_vec.Vec3f32, ray_origin: maths_vec.Vec3f32) !HitResult {
    return check_ray_hit_implicit_sphere(
        ray_direction,
        ray_origin,
        maths_vec.Vec3f32.create_origin(),
        1000000,
    );
}
