module.exports = function(Sequelize, DataTypes) {
  var schema = {
    shotNumber: {
      type: DataTypes.INTEGER,
      unique: 'shotNumberFrame',
      allowNull: false
    },
    attempt: {
      type: DataTypes.ENUM("pot", "shotToNothing", "safety")
    },
    result: {
      type: DataTypes.ENUM("pot", "nothing", "foul"),
      allowNull: false
    },
    points: {
      type: DataTypes.INTEGER, // Negative integers are fouls
      allowNull: false,
      validate: {
        min: -7,
        max: 16
      }
    },
    redsOffTable: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: 0,
        max: 15
      }
    }
  };

  var Shot = Sequelize.define("Shot", schema, {
      classMethods: {
        associate: function(models) {
          Shot.belongsTo(models.Frame, { foreignKey: {allowNull: false, unique: 'shotNumberFrame' }, onDelete: "RESTRICT" });
          Shot.belongsTo(models.Player, { as: 'Player', foreignKey: {allowNull: false}, onDelete: "RESTRICT" });
        }
      }
    }
  );

  return Shot;
};
