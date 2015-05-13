module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    name: { type: DataTypes.STRING, allowNull: false, unique: true, validate: { len: [3,50] } }
  };
  var League = Sequelize.define("League", schema, {
      classMethods: {
        associate: function(models) {
          League.belongsToMany(models.User, { as: 'Admins', through: "Admin" });
          League.hasMany(models.Player);
        }
      }
    }
  )

  return League;
};
