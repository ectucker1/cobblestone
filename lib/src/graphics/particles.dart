part of cobblestone;

/// Loads a particle effect exported by https://pixijs.io/pixi-particles-editor/.
Future<ParticleEffect> loadEffect(
    String effectUrl, Future<Texture> texture) async {
  var effectData = json.decode(await HttpRequest.getString(effectUrl));
  Texture effectTexture = await texture;
  return ParticleEffect.fromJSON(effectData, effectTexture);
}

/// The type of spawn pattern particles are created in.
enum SpawnType {
  /// Spawns all particles at a single point.
  point,

  /// Spawns particles randomly within a rectangle.
  rect,

  /// Spawns particles randomly within a circle.
  circle,

  /// Spawns particles randomly inside a ring.
  ring,

  /// Spawns particles in a burst pattern around a point.
  burst
}

/// All the information needed to emit particles.
/// Use with [ParticleEmitter].
class ParticleEffect {
  // Particle Properties

  /// The texture used by particles of this effect.
  Texture texture;

  /// A particle's color at the start of its lifespan.
  Vector4 colorStart;

  /// A particle's color at the end of its lifespan.
  Vector4 colorEnd;

  /// A particle's speed at the start of its lifespan.
  double speedStart;

  /// A particle's speed at the start of its lifespan.
  double speedEnd;

  /// Randomization multiplier for speed.
  ///
  /// A number between 1 and this value is chosen for each particle and used to multiply its [speedStart] and [speedEnd].
  double speedMultiplier;

  /// A particle's scale at the start of its lifespan.
  double scaleStart;

  /// A particle's scale at the start of its lifespan.
  double scaleEnd;

  /// Randomization multiplier for scale.
  ///
  /// A number between 1 and this value is chosen for each particle and used to multiply its [scaleStart] and [scaleEnd].
  double scaleMultiplier;

  /// The acceleration vector of particles.
  ///
  /// Overrides [endSpeed] if nonzero.
  Vector2 acceleration;

  /// The maximum speed of a particle using [acceleration].
  double maxSpeed;

  /// The minimum angle at which a particle can spawn.
  ///
  /// Ignored for [SpawnType.burst].
  double minStartRotation;

  /// The maximum angle at which a particle can spawn.
  ///
  /// Ignored for [SpawnType.burst].
  double maxStartRotation;

  /// Minimum possible rotation speed over time.
  double minRotationSpeed;

  /// Maximum possible rotation speed over time.
  double maxRotationSpeed;

  /// Minimum possible lifetime of a particle.
  double minLifetime;

  /// Maximum possible lifetime of a particle.
  double maxLifetime;

  // Emitter properties

  /// Time between each particle spawn.
  double spawnFrequency;

  /// Duration for which an emitter is active.
  double emitterLifetime;

  /// Maximum number of particles stored in an emitter.
  int maxParticles;

  /// The pattern in which particles are spawned.
  SpawnType type;

  /// Offset from emitter position where particles are spawned.
  Vector2 emitterOffset;

  /// Position of the [SpawnType.rect] rectangle relative to an emitter.
  Vector2 rectPos;

  /// Size of the [SpawnType.rect] rectangle.
  Vector2 rectSize;

  /// Position of the [SpawnType.circle] circle relative to an emitter.
  Vector2 circlePos;

  /// Radius of the [SpawnType.circle] circle.
  double circleRadius;

  /// Position of the [SpawnType.ring] area relative to an emitter.
  Vector2 ringPos;

  /// Radius to the inside edge of the [SpawnType.ring] area.
  double minRingRadius;

  /// Radius to the outside edge of the [SpawnType.ring] area.
  double maxRingRadius;

  /// Number of particles in each [SpawnType.burst] burst.
  int burstParticlesPerWave;

  /// Spacing between particles in each [SpawnType.burst] burst.
  double burstParticleSpacing;

  /// First angle for a particle in a [SpawnType.burst] burst.
  double burstStartAngle;

  /// Creates a particle effect with the given [texture].
  ///
  /// Properties must be set manually.
  ParticleEffect(this.texture);

  /// Creates a particle effect from JSON data.
  /// See [loadParticle].
  ParticleEffect.fromJSON(var data, this.texture) {
    colorStart = Vector4.zero();
    Colors.fromHexString(data['color']['start'], colorStart);
    colorStart.a = data['alpha']['start'];

    colorEnd = Vector4.zero();
    Colors.fromHexString(data['color']['end'], colorEnd);
    colorEnd.a = data['alpha']['end'];

    scaleStart = data['scale']['start'];
    scaleEnd = data['scale']['end'];
    scaleMultiplier = data['scale']['minimumScaleMultiplier'];

    speedStart = data['speed']['start'];
    speedEnd = data['speed']['end'];
    speedMultiplier = data['speed']['minimumSpeedMultiplier'];

    acceleration =
        Vector2(data['acceleration']['x'], data['acceleration']['y']);
    maxSpeed = data['maxSpeed'];

    minStartRotation = data['startRotation']['min'];
    maxStartRotation = data['startRotation']['max'];

    minRotationSpeed = data['rotationSpeed']['min'];
    maxRotationSpeed = data['rotationSpeed']['max'];

    minLifetime = data['lifetime']['min'];
    maxLifetime = data['lifetime']['max'];

    spawnFrequency = data['frequency'];
    emitterLifetime = data['emitterLifetime'];
    maxParticles = data['maxParticles'];

    emitterOffset = Vector2(data['pos']['x'], data['pos']['y']);

    type = SpawnType.values
        .firstWhere((e) => e.toString() == 'SpawnType.' + data['spawnType']);

    switch (type) {
      case SpawnType.point:
        break;
      case SpawnType.burst:
        burstParticlesPerWave = data['particlesPerWave'];
        burstParticleSpacing = data['particleSpacing'];
        burstStartAngle = data['angleStart'];
        break;
      case SpawnType.circle:
        circlePos = Vector2(data['spawnCircle']['x'], data['spawnCircle']['y']);
        circleRadius = data['spawnCircle']['r'];
        break;
      case SpawnType.rect:
        rectPos = Vector2(data['spawnRect']['x'], data['spawnRect']['y']);
        rectSize = Vector2(data['spawnRect']['w'], data['spawnRect']['h']);
        break;
      case SpawnType.ring:
        ringPos = Vector2(data['spawnCircle']['x'], data['spawnCircle']['y']);
        minRingRadius = data['spawnCircle']['minR'];
        maxRingRadius = data['spawnCircle']['r'];
        break;
    }
  }
}

/// An emitter for particles, with behavior controlled by a [ParticleEffect].
class ParticleEmitter {
  /// The particle effect that determines the emitter's behavior.
  ParticleEffect effect;

  /// Random number generator used by emitter.
  Random rand;

  /// The position of the particle emitter.
  ///
  /// New particles will be spawned around here.
  Vector2 pos;

  double _time = 0.0;
  double _totalTime = 0.0;

  /// A list of all active particles
  List<Particle> particles;

  List<Particle> _toRemove;

  /// Creates a particle emitter using the given effect.
  ParticleEmitter(this.effect, [this.rand]) {
    rand ??= Random();
    pos = Vector2.zero();
    particles = [];
    _toRemove = [];
  }

  /// Updates all the live particles emitted.
  void update(double delta) {
    _toRemove.clear();
    for (Particle particle in particles) {
      particle.update(delta);
      if (particle._time > particle.lifetime) {
        _toRemove.add(particle);
      }
    }
    for (Particle particle in _toRemove) {
      particles.remove(particle);
    }

    _time += delta;
    _totalTime += delta;
    if (_totalTime < effect.emitterLifetime ||
        effect.emitterLifetime == 0 ||
        effect.emitterLifetime == -1) {
      while (_time >= effect.spawnFrequency) {
        spawnWave();
        _time -= effect.spawnFrequency;
      }
    }
  }

  /// Draws all emitted particles in the given [batch].
  void draw(SpriteBatch batch) {
    for (Particle particle in particles) {
      batch.color = particle.color;
      batch.draw(
          particle.texture,
          particle.position.x - (particle.texture.width * particle.scale * 0.5),
          particle.position.y -
              (particle.texture.height * particle.scale * 0.5),
          scaleX: particle.scale,
          scaleY: particle.scale,
          angle: radians(particle.rotation));
    }
  }

  /// Spawns a wave of particles, using the effect's spawn type.
  void spawnWave() {
    switch (effect.type) {
      case SpawnType.point:
        spawnParticle(pos + effect.emitterOffset);
        break;
      case SpawnType.burst:
        double angle = 360 - effect.burstStartAngle;
        for (int i = 0; i < effect.burstParticlesPerWave; i++) {
          angle += effect.burstParticleSpacing;
          if (effect.burstParticleSpacing == 0) {
            angle = _randBetween(0.0, 360.0);
          }
          spawnParticle(pos + effect.emitterOffset, angle);
        }
        break;
      case SpawnType.circle:
        double angle = _randBetween(-pi, pi);
        spawnParticle(pos +
            effect.circlePos +
            (_angleToVec(angle) * effect.circleRadius * rand.nextDouble()) +
            effect.emitterOffset);
        break;
      case SpawnType.rect:
        spawnParticle(pos +
            effect.rectPos +
            Vector2(effect.rectSize.x * rand.nextDouble(),
                effect.rectSize.y * rand.nextDouble()) +
            effect.emitterOffset);
        break;
      case SpawnType.ring:
        double angle = _randBetween(-pi, pi);
        spawnParticle(pos +
            effect.circlePos +
            (Vector2(cos(angle), sin(angle)) *
                _randBetween(effect.minRingRadius, effect.maxRingRadius)) +
            effect.emitterOffset);
        break;
    }
  }

  /// Spawns a single particle at [pos] moving in direction [angle].
  void spawnParticle(Vector2 pos, [double angle]) {
    if (particles.length < effect.maxParticles) {
      Particle particle = Particle(effect);
      particle.texture = effect.texture;
      particle.color = effect.colorStart.clone();
      particle.rotation = -(angle ??
          _randBetween(effect.minStartRotation, effect.maxStartRotation));
      particle.rotationSpeed =
          _randBetween(effect.minRotationSpeed, effect.maxRotationSpeed);
      particle.scaleMod = _randBetween(1.0, effect.scaleMultiplier);
      particle.scale = effect.scaleStart * particle.scaleMod;
      particle.speedMod = _randBetween(1.0, effect.speedMultiplier);
      particle.speed = effect.speedStart * particle.speedMod;
      particle.lifetime = _randBetween(effect.minLifetime, effect.maxLifetime);
      particle.velocity = _angleToVec(radians(particle.rotation));
      particle.position = pos;
      particles.add(particle);
    }
  }

  double _randBetween(double a, double b) {
    double low = min(a, b);
    double high = max(a, b);
    return low + rand.nextDouble() * (high - low);
  }
}

/// A single particle.
///
/// Should generally be created using a [ParticleEmitter].
class Particle {
  /// The effect that determines the particle's behavior.
  ParticleEffect effect;

  /// The texture of the particle.
  Texture texture;

  /// The current color of the particle.
  Vector4 color;

  /// The position of the particle.
  Vector2 position;

  /// The velocity of the particle.
  Vector2 velocity;

  /// The current scale of the particle.
  double scale;

  /// The scale multiplier for this particle.
  ///
  /// The normal start and end speed are multiplied by this value.
  double scaleMod;

  /// The current speed of the particle.
  double speed;

  /// The speed multiplier for this particle.
  ///
  /// The normal start and end speed are multiplied by this value.
  double speedMod;

  /// The current rotation of this particle, in degrees.
  double rotation;

  /// The rotation speed of this particle, in degrees.
  double rotationSpeed;

  /// The lifetime of this particle.
  double lifetime;

  // The time this particle has been alive.
  double _time = 0;

  /// Creates a particle of the given effect.
  ///
  /// Most values are set manually, typically by a [ParticleEmitter]
  Particle(this.effect);

  /// Updates the individual particle over time.
  void update(double delta) {
    _time += delta;

    color += (effect.colorEnd - effect.colorStart) * (delta / lifetime);

    rotation -= rotationSpeed * delta;

    scale +=
        (effect.scaleEnd - effect.scaleStart) * scaleMod * (delta / lifetime);

    speed +=
        (effect.speedEnd - effect.speedStart) * speedMod * (delta / lifetime);

    if (effect.acceleration != Vector2.zero()) {
      velocity += effect.acceleration * delta;
      if (velocity.length > effect.maxSpeed) {
        velocity.length = effect.maxSpeed;
      }
    } else {
      velocity = velocity.normalized() * speed;
    }
    position += velocity * delta;
  }
}

// Converts an angle in radians to a vector of length 1
Vector2 _angleToVec(double angle) {
  Vector2 result = Vector2(cos(angle), sin(angle));
  if (result.x.abs() < 0.0001) {
    result.x = 0;
  }
  if (result.y.abs() < 0.0001) {
    result.y = 0;
  }
  return result;
}
