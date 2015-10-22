module.exports = function(Sequelize, DataTypes) {
  var schema = {
    FrameId: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: 'shotNumberFrame'
    },
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
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 0,
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
          Shot.belongsTo(models.Frame, { foreignKey: 'FrameId', onDelete: "CASCADE" });
          Shot.belongsTo(models.Player, { as: 'Player', foreignKey: {allowNull: false}, onDelete: "CASCADE" });
        }
      },
      validate: {
        foulPoints: function() {
          if ((this.result === "foul") && ((this.points < 4) || (this.points > 7))) {
            throw new Error('Foul points must be 4 - 7')
          }
        }
      }
    }
  );

  return Shot;
};
