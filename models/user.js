module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    email: { type: DataTypes.STRING, allowNull: false }
  };

  var options = {};

  var User = Sequelize.define("User", schema, options);

  return User;
};
