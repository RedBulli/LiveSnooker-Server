module.exports = function(Sequelize, DataTypes) {
  var schema = {
    shotNumberStart: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: 'breakStartShotNumberFrame'
    },
    showNumberEnd: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    points: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 155
      }
    }
  };
  var Break = Sequelize.define("Break", schema, {
      classMethods: {
        associate: function(models) {
          Break.belongsTo(models.Frame, { foreignKey: {allowNull: false, unique: 'breakStartShotNumberFrame' }, onDelete: "CASCADE" });
          Break.belongsTo(models.Player, { as: 'Player', foreignKey: {allowNull: false}, onDelete: "CASCADE" });
        }
      }
    }
  );

  return Break;
};
