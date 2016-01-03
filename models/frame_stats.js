module.exports = function(Sequelize, DataTypes) {
  var schema = {
    potAttempts: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    safetyAttempts: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    potsFromPotAttempts: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    potsFromSafeties: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    safetyFailCount: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    totalPoints: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    failCount: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    failPoints: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    biggestBreak: {
      type: DataTypes.INTEGER,
      allowNull: false
    }
  };
  var FrameStats = Sequelize.define('FrameStats', schema, {
      classMethods: {
        associate: function(models) {
          FrameStats.belongsTo(models.Frame, { foreignKey: {allowNull: false, unique: 'frameStatsPlayerUnique' }, onDelete: 'CASCADE' });
          FrameStats.belongsTo(models.Player, { as: 'Player', foreignKey: {allowNull: false, unique: 'frameStatsPlayerUnique'}, onDelete: 'CASCADE' });
        }
      }
    }
  );

  return FrameStats;
};
